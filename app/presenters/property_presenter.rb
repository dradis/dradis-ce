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
    #
    # NB new services will always be an array; legacy data may not be
    if (property_key == 'services') && !property_value.is_a?(Array)
      property[1] = [property[1]]
    end

    # 'services' and 'services_extras' are special cases:
    if property_key == 'services'
      render 'nodes/show/services_table', services: property_value
    elsif property_key == 'services_extras'
      render 'nodes/show/services_extras_table', extras: property_value
    elsif property_value.is_a?(Array)
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

  def render_table
    values         = property_value
    column_names   = values.map(&:keys).flatten.uniq.sort.map(&:to_sym).
                     delete_if{ |cn| !services_table_columns.include?(cn) }
    table          = table_info(
      values: values,
      sort_by_port: column_names.include?(:port)
    )

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

  def services_table_columns
    NodeProperties::SERVICE_KEYS
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
