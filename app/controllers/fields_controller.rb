class FieldsController < AuthenticatedController
  # Returns the form view given a source text
  def form
    @editor_id = field_params[:editor_id]
    @form_data = FieldParser.source_to_fields_array(field_params[:source])
    @field_values = field_params[:field_values]&.to_h
    render layout: false
  end

  # Returns a single field for the form view
  def field
    @editor_id = field_params[:editor_id]
    @index = field_params[:index].to_i
  end

  # Returns the source text given a form data
  def source
    render plain: FieldParser.fields_to_source(field_params[:form])
  end

  private

  def field_params
    params.permit(:editor_id, :index, :source, field_values: {}, form: [:name, :value])
  end
end
