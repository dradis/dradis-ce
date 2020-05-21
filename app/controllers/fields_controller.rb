class FieldsController < AuthenticatedController
  # Returns the form view given a source text
  def form
    @form_data = FieldParser.source_to_fields(params[:source])

    if fieldless_string.present?
      @form_data = { '': fieldless_string }.merge(@form_data)
    end

    @allow_dropdown = params[:allow_dropdown] == 'true'
  end

  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the source text given a form data
  def source
    render plain: FieldParser.fields_to_source(params[:form])
  end

  private

  def fieldless_string
    @fieldless_string ||= FieldParser.parse_fieldless_string(params[:source])
  end
end
