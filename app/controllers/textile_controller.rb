class TextileController < AuthenticatedController
  include FormDradifier

  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the form view given a source text
  def form
    @form_data = Note.parse_fields(params[:source]) if params[:source]
    @allow_dropdown = JSON.parse(params[:allow_dropdown] || 'false')

    render layout: false
  end

  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def markup_help
    render layout: false
  end

  # Returns the source test given a form data
  def source
    # Reformat the params to be dradified
    form_params = JSON.parse(params[:form]).map do |field|
      [field['key'], field['value']]
    end || []

    render plain: dradify_form(form_data: form_params)
  end

  # Returns the Textile version of a text passed as parameter
  def textilize
    render layout: false
  end
end
