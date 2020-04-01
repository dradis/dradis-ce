module FormDradifier
  extend ActiveSupport::Concern

  protected

  # Convert serialized form data to Dradis-style item content
  def dradify_form(options = {})
    form_data = options[:form_data] || item_form_params.to_h

    form_data.each_slice(2).map do |field_name, field_value|
      field = field_name[1]
      value = field_value[1]
      next if field.empty? || (field.empty? && value.empty?)

      "#[#{field}]#\n#{value}"
    end.compact.join("\n\n")
  end

  def item_form_params
    params.require(:item_form).permit!
  end
end
