class FieldsController < AuthenticatedController
  before_action :set_target_id

  # Returns the form view given a source text
  def form
    @form_data = FieldParser.source_to_fields_array(params[:source])
    @allow_dropdown = params[:allow_dropdown] == 'true'
    render layout: false
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

  def set_target_id
    @target_id = params[:target]
  end
end
