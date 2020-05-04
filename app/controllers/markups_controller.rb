class MarkupsController < AuthenticatedController
  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def help
    render layout: false
  end

  # Returns the Textile version of a text passed as parameter
  def preview
    @text =
      if params[:form]
        FieldParser.convert_to_source(form_params)
      else
        params[:text]
      end

    render layout: false
  end

  private

  # Reformatted form parameters to be converted to source
  def form_params
    JSON.parse(params[:form]).map do |field|
      [field['key'], field['value']]
    end || []
  end
end
