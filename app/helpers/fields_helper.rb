module FieldsHelper
  def render_dropdown?(field_name, value)
    options = list_field_options(field_name)
    options.present? && (value.blank? || options.include?(value))
  end

  def dropdown_options(field_name)
    list_field_options(field_name)
  end

  private

  def list_field_options(field_name)
    @field_options && @field_options[field_name]
  end
end
