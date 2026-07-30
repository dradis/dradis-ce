module FieldsHelper
  def dropdown_options(field_name, value)
    options = list_field_options(field_name)

    if options
      options if value.blank? || options.include?(value)
    elsif @allow_dropdown && !has_liquid_filters?(value)
      values = value.split(' | ')
      values if values.count > 1
    end
  end

  private

  def has_liquid_filters?(text)
    HTML::Pipeline::Dradis::LiquidFilter::LIQUID_FILTER_PATTERNS.any? { |liquid_pattern| text.match?(liquid_pattern) }
  end

  def list_field_options(field_name)
    @field_options && @field_options[field_name]
  end
end
