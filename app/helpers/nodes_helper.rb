module NodesHelper # :nodoc:
  def short_filename(long_filename)
    # hyphens are word-wrapped by the browser
    return long_filename if long_filename =~ /\-/

    return truncate(long_filename, length: 20)
  end

  def render_property(node, property)
    return if node.properties[property].blank?
    if node.properties[property].is_a?(Array)
      node.properties[property].join(", ")
    else
      node.properties[property]
    end
  end

  def render_property_table(node, property)
    values = node.properties[property]
    return if values.blank?

    # There is the rare occasion in which a single port is open in a node, this
    # creates a :services property with a single nested object, but still want
    # to render it as an array.
    if property == 'services' && !values.is_a?(Array)
      values = [values]
    end

    column_names = values.map(&:keys).flatten.uniq.sort.map(&:to_sym)
    sorted_entries = column_names.include?(:port) ? values.sort_by{ |h| h[:port].to_i } : values

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

    content_tag :table, thead.concat(tbody)
  end

end
