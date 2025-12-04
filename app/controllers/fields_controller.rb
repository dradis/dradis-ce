class FieldsController < AuthenticatedController
  TEXTILE_FORM_REGEX = /\Atextile_form_body_[0-9a-fA-F]{8}\z/

  before_action :set_target_id, only: [:field]

  # Returns the form view given a source text
  def form
    @form_data = FieldParser.source_to_fields_array(params[:source])
    @allow_dropdown = params[:allow_dropdown] == 'true'
    @target_dom_id = "textile_form_body_#{SecureRandom.hex(4)}"
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
    if params[:target] =~ TEXTILE_FORM_REGEX
      @target_id = params[:target]
    end
  end
end
