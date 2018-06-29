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
      services = property_value.sort_by { |v| v['port'] }
      render 'nodes/show/services_table', services: services
    elsif property_key == 'services_extras'
      # We want to sort the table by port number - but property_value is and
      # must remain a Hash, and Hash#sort_by returns an Array.  Hacky solution
      # is to build a new Hash with the keys in the correct order:

      # (The `to_i` is important here so that e.g. '100' appears after '20')
      keys   = property_value.keys.sort_by { |k| k.split('/').last.to_i }
      extras = keys.each_with_object({}) { |k, h| h[k] = property_value[k] }
      render 'nodes/show/services_extras_table', extras: extras
    elsif property_value.is_a?(Array)
      if property_value.all? { |x| x.is_a?(Hash) }
        render_table
      else
        content_tag(:p, property_value.join(', '))
      end
    else
      if property_value =~ /\n/
        content_tag(:pre, property_value)
      else
        content_tag(:p, property_value)
      end
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
    column_names = property_value.map(&:keys).flatten.uniq.sort.map(&:to_s)

    thead = content_tag(:thead) do
      content_tag(:tr) do
        column_names.collect do |column_name|
          concat content_tag(:th, column_name)
        end.join.html_safe
      end
    end

    tbody = content_tag(:tbody) do
      property_value.map do |entry|
        content_tag(:tr) do
          column_names.collect do |column_name|
            concat content_tag(:td, entry[column_name])
          end.join.html_safe
        end
      end.join.html_safe
    end

    content_tag(
      :div,
      content_tag(:table, thead.concat(tbody)),
      class: 'content-textile',
    )
  end
end
