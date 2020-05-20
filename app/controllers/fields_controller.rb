class FieldsController < AuthenticatedController
  # Returns the form view given a source text
  def form
    @form_data = HasFields.parse_fields(params[:source])
    @allow_dropdown = params[:allow_dropdown] == 'true'
  end

  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the source text given a form data
  def source
    render plain: convert_to_source
  end

  private

  # Convert serialized form data to Dradis-style item content
  def convert_to_source
    params[:form].each_slice(2).map do |field_name, field_value|
      field = field_name[:value]
      value = field_value[:value]
      next if field.empty?

      "#[#{field}]#\n#{value}"
    end.compact.join("\n\n")
  end
end
