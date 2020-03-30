class TextileController < AuthenticatedController
  include FormDradifier

  def form
    @form_data = Note.parse_fields(params[:source]) if params[:source]

    render layout: false
  end

  def field
    @index = params[:index].to_i
  end

  def source
    # Reformat the params to be dradified
    form_params = JSON.parse(params[:form]).map do |field|
      [field['key'], field['value']]
    end

    render plain: dradify_form(form_params)
  end
end
