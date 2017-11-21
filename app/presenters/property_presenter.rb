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
        content_tag(:p, property_value.join(', '))
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

  def render_services_extra_table(entry)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        content_tag(:th, 'source').
          concat(content_tag(:th, 'id')).
            concat(content_tag(:th, 'output'))
      end
    end
    tbody = content_tag(:tbody) do
      entry[:extra].map do |extra|
        content_tag(:tr) do
          content_tag(:td, extra[:source]).
            concat(content_tag(:td, extra[:id])).
              concat(content_tag(:td, content_tag(:pre, extra[:output])))
        end
      end.join.html_safe
    end

    content_tag(:table, thead.concat(tbody), class: 'table table-condensed')
  end

  def render_table
    values         = property_value
    column_names   = values.map(&:keys).flatten.uniq.sort.map(&:to_sym)
    sorted_entries =
      if column_names.include?(:port)
        values.sort_by { |h| h[:port] }
      else
        values
      end

    output =
      if property_key == 'services_extra'
        render_tabs(sorted_entries)
      else
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
        )
      end

    output.html_safe
  end

  def render_tab_content(values)
    content_tag(:div, class: 'tab-content') do
      values.map do |entry|
        content_tag(:div, class: 'tab-pane', id: "#{entry[:protocol]}-#{entry[:port]}-tab") do
          render_services_extra_table(entry)
        end
      end.join.html_safe
    end
  end

  def render_tab_ul(values)
    content_tag :ul, class: 'nav nav-tabs' do
      values.map do |entry|
        content_tag :li do
          content_tag(:a,
            '%s/%d' % [entry[:protocol], entry[:port]],
            data: { toggle: :tab },
            href: '#%s-%d-tab' % [entry[:protocol], entry[:port]]
          )
        end
      end.join.html_safe
    end
  end

  def render_tabs(entries)
    return if entries.empty?

    content_tag(:div, class: 'tabbable tabs-left', id: 'scripts-tabs') do
      concat(render_tab_ul(entries)).
      concat(render_tab_content(entries))
    end
  end
end
