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

  def render_scripts_table(entries)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        content_tag(:th, 'id').concat(content_tag(:th, 'output'))
      end
    end
    tbody = content_tag(:tbody) do
      entries.map do |entry|
        entry.map do |k,v|
          next if [:port, :protocol].include?(k.to_sym)
          if v.respond_to?(:map)
            v.map do |script|
              content_tag(:tr) do
                content_tag(:td, "Nmap NSE script: #{script[0]}").
                  concat content_tag(:td, content_tag(:pre, script[1]))
              end
            end.join.html_safe
          else
            content_tag(:tr) do
              content_tag(:td, k).concat(content_tag(:td, v))
            end
          end
        end.join.html_safe
      end.join.html_safe
    end

    content_tag(:table, thead.concat(tbody), class: 'table table-condensed')
  end

  def render_table
    values         = property_value
    column_names   = values.map(&:keys).flatten.uniq.sort.map(&:to_sym).
                     delete_if{ |cn| !services_table_columns.include?(cn) }
    supplemental   = supplemental_info(values)
    table          = table_info(
      values: values,
      sort_by_port: column_names.include?(:port)
    )
    output = supplemental.any? ? render_tabs(supplemental) : ''

    thead = content_tag(:thead) do
      content_tag(:tr) do
        column_names.collect do |column_name|
          concat content_tag(:th, column_name)
        end.join.html_safe
      end
    end

    tbody = content_tag(:tbody) do
      table.collect do |entry|
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
      supplemental_keys(values).map do |group_key|
        content_tag(:div, class: 'tab-pane', id: "#{group_key[:protocol]}-#{group_key[:port]}-tab") do
          render_scripts_table(supplemental_value(group_key, values))
        end
      end.join.html_safe
    end
  end

  def render_tab_ul(values)
    content_tag :ul, class: 'nav nav-tabs' do
      supplemental_keys(values).map do |entry|
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
    content_tag(:h4, 'Supplemental Data') +
    content_tag(:div, class: 'tabbable tabs-left', id: 'scripts-tabs') do
      concat(render_tab_ul(entries)).
      concat(render_tab_content(entries))
    end
  end

  def merge_rows(rows)
    rows.group_by{|e| [e[:port], e[:protocol]]}.map do |_, a|
      a.reduce do |memo, row|
        memo.merge(row) do |_key, oldvalue, newvalue|
          if oldvalue == newvalue
            oldvalue
          elsif oldvalue.respond_to?(:concat)
            backupvalue = oldvalue.clone
            backupvalue.concat(content_tag(:br)).concat(newvalue).html_safe
          elsif oldvalue.respond_to?(:merge)
            oldvalue.merge(newvalue)
          end
        end
      end
    end
  end

  # A list of the allowed columns in services table
  def services_table_columns
    [:name, :port, :product, :protocol, :reason, :state, :version]
  end

  # Prepare info to be displayed in services table
  # converts
  # [ {"port" => 80, "protocol" => "tcp", "name" => "foo", "x_nessus" => "xyz1" },
  #   {"port" => 22, "name" => "bar", "scripts" => "xyz2"},
  #   {"port" => 80, "protocol" => "udp", "name" => "baz", "x_nessus" => "xyz3"}, ... ]
  # to
  # [ {port: 80, protocol: 'tcp'} => [
  #      {port: 80, protocol: 'tcp', x_nessus: "xyz1"},
  #      {port: 80, protocol: 'tcp', x_nessus: "xyz2"}
  #   ],
  #   {port: 22, protocol: 'udp'} => [
  #      {"port" => 22, "name" => "bar", "scripts" => "xyz2"}
  #   ],
  #   ...
  # ]
  # Groups entries by port/protocol, but every port/protocol pair returns an
  # array of the values with those port and protocol (doesn't merge them).
  # The hashes in the array don't contain keys in `services_table_columns`,
  # except port and column.
  def supplemental_info(values)
    filtered = values.map do |se|
      se.reject do |k, v|
        (services_table_columns - [:port, :protocol]).include?(k.to_sym) ||
        v.try(:empty?)
      end
    end
    no_empty = filtered.reject{ |h| h.keys == %w(port protocol) }
    grouped = no_empty.group_by{ |e| [e[:port], e[:protocol]] }
    grouped.map{|k,v| { { port: k[0], protocol: k[1] } => v } }
  end

  # converts
  # [ {port: 80, protocol: 'tcp'} => [...],
  #    port: 80, protocol: 'udp'} => [...], ... ]
  # to
  # [ {port: 80, protocol: 'tcp'}, {port: 80, protocol: 'udp'}, ... ]
  def supplemental_keys(values)
    values.map(&:keys).flatten
  end

  # from values
  # [ {port: 80, protocol: 'tcp'} => [foo],
  #    port: 80, protocol: 'udp'} => [bar], ... ]
  # with a key like {port: 80, protocol: 'tcp'} returns
  # [foo]
  def supplemental_value(group_key, values)
    values.select{|h| h[group_key]}.map(&:values).flatten
  end

  # Prepare info to be displayed in services table
  # converts
  # [ {"port" => 80, "name" => "foo"},
  #   {"port" => 22, "name" => "bar"},
  #   {"port" => 80, "name" => "baz"}, ... ]
  # into
  # [ {"port" => 22, "name" => "baz"},
  #   {"port" => 80, "name" => "foo<br></br>bar"}, ... ]
  # Id sort_by_port is true it merges duplicated rows by [port/protocol],
  # adding duplicted values with <br/><br/>
  # It always filters the keys to those available in `services_table_columns`
  def table_info(values:, sort_by_port:)
    if sort_by_port
      merge_rows(values).sort_by{ |h| h[:port] }
    else
      values
    end.map do |se|
      se.select{ |k, _| services_table_columns.include?(k.to_sym) }
    end
  end
end
