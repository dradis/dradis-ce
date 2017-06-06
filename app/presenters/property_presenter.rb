class PropertyPresenter < BasePresenter
  presents :property

  def name
    if property_value.is_a?(Array) || property_value.is_a?(Hash)
      property_key.to_s.pluralize.titleize
    else
      property_key.to_s.titleize.singularize
    end
  end

  def value
    return 'n/a' unless property_value.present?

    # We want to always render :services as table, but some times there is a
    # single port. We just turn it into a single-element array
    if (property_key == 'services') && !property_value.is_a?(Array)
      property[1] = [property[1]]
    end

    if property_value.is_a?(Array)
      if property_value[0].is_a?(Hash)
        render_table
      else
        content_tag(:p, property_value.join(", "))
      end

    else
      content_tag(:p, property_value)
    end
  end

  private

  def property_key
    property[0]
  end

  def property_value
    property[1]
  end

  def render_scripts_table(entry)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        content_tag(:th, 'id').
          concat(content_tag(:th, 'output'))
      end
    end
    tbody = content_tag(:tbody) do
      entry[:scripts].map do |script|
        content_tag(:tr) do
          content_tag(:td, script[0]).
            concat content_tag(:td, content_tag(:pre, script[1]))
        end
      end.join.html_safe
    end

    # content_tag(:div,
    #   content_tag(:table, thead.concat(tbody)),
    #   class: 'content-textile'
    # )
    content_tag(:table, thead.concat(tbody), class: 'table table-condensed')
  end

  def render_table
    values         = property_value
    column_names   = values.map(&:keys).flatten.uniq.sort.map(&:to_sym)
    sorted_entries = column_names.include?(:port) ? merge_entries(values).sort_by{ |h| h[:port] } : values

    output = if column_names.delete(:scripts)
               render_tabs(sorted_entries)
             else
               ''
             end

    thead = content_tag(:thead) do
      content_tag(:tr) do
        column_names.collect do |column_name|
          concat content_tag(:th, column_name)
        end.join.html_safe
      end
    end

    tbody = content_tag(:tbody) do
      sorted_entries.collect do |entry|
        content_tag(:tr) do
          column_names.collect do |column_name|
            concat content_tag(:td, entry[column_name])
          end.join.html_safe
        end
      end.join.html_safe
    end

    content_tag(:div,
      content_tag(:table, thead.concat(tbody)),
      class: 'content-textile'
    ).concat(output)
  end

  def render_tab_content(values)
    content_tag(:div, class: 'tab-content') do
      values.map do |entry|
        content_tag(:div, class: 'tab-pane', id: "#{entry[:protocol]}-#{entry[:port]}-tab") do
          render_scripts_table(entry)
        end
      end.join.html_safe
    end
  end

  def render_tab_ul(values)
    content_tag :ul, class: 'nav nav-tabs' do
      values.map do |entry|
        content_tag :li do
          content_tag(:a,
            "%s/%d" % [entry[:protocol], entry[:port]],
            data: { toggle: :tab },
            href: "#%s-%d-tab" % [entry[:protocol], entry[:port]]
          )
        end
      end.join.html_safe
    end
  end

  def render_tabs(entries)
    values = entries.select{ |entry| entry.key?(:scripts) && entry[:scripts].any? }
    return if values.empty?

    content_tag(:h4, 'NSE script output') +
    content_tag(:div, class: 'tabbable tabs-left', id: 'scripts-tabs') do
      concat(render_tab_ul(values)).
      concat(render_tab_content(values))
    end
  end

  def merge_entries(entries)
    entries.group_by{|e| [e[:port], e[:protocol]]}.map do |_, a|
      a.reduce do |memo, row|
        memo.merge!(row) do |_key, oldvalue, newvalue|
          if oldvalue == newvalue
            oldvalue
          else
            oldvalue.concat(content_tag(:br)).concat(newvalue).html_safe
          end
        end
      end
    end
  end
end
