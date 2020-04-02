module FormDradifier
  extend ActiveSupport::Concern

  def convert_form_content
    return unless params[:item_form]

    item = instance_variable_get("@#{controller_name.singularize}")
    # Assign the issue for the Issues::MergeController
    item = @issue if controller_name.singularize == 'merge'

    content_attribute =
      case item
      when Card; :description
      when Issue, Note; :text
      when Evidence; :content
      end

    item.send("#{content_attribute}=", dradify_form)
  end

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
