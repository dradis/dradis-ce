module FieldsHelper
  def render_dropdown?(value)
    @allow_dropdown &&
    !has_liquid_filters?(value) &&
    value.split(' | ').count > 1
  end

  private

  def has_liquid_filters?(text)
    HTML::Pipeline::Dradis::LiquidFilter::LIQUID_FILTER_PATTERNS.any? { |liquid_pattern| text.match?(liquid_pattern) }
  end
end
