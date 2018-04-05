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
