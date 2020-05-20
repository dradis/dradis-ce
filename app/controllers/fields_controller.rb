class FieldsController < AuthenticatedController
  # Returns the form view given a source text
  def form
    @form_data = HasFields.source_to_fields(params[:source])
    @allow_dropdown = params[:allow_dropdown] == 'true'
  end

  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the source text given a form data
  def source
    render plain: HasFields.fields_to_source(params[:form])
  end
end
