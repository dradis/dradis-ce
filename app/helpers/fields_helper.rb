module FieldsHelper
  def render_dropdown?(field_name, value)
    if (options = list_field_options(field_name))
      value.blank? || options.include?(value)
    else
      @allow_dropdown &&
      !has_liquid_filters?(value) &&
      value.split(' | ').count > 1
    end
  end

  def dropdown_options(field_name, value)
    list_field_options(field_name) || value.split(' | ')
  end

  private

  def list_field_options(field_name)
    @field_options && @field_options[field_name]
  end

  def has_liquid_filters?(text)
    HTML::Pipeline::Dradis::LiquidFilter::LIQUID_FILTER_PATTERNS.any? { |liquid_pattern| text.match?(liquid_pattern) }
  end
end
