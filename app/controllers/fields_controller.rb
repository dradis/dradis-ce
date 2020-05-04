class FieldsController < AuthenticatedController
  # Returns the form view given a source text
  def form
    @form_data = FieldParser.parse_fields(params[:source]) if params[:source]
    @allow_dropdown = JSON.parse(params[:allow_dropdown] || 'false')
  end

  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the source text given a form data
  def source
    render plain: FieldParser.convert_to_source(form_params)
  end

  private

  # Reformatted form parameters to be converted to source
  def form_params
    JSON.parse(params[:form]).map do |field|
      [field['key'], field['value']]
    end || []
  end
end
