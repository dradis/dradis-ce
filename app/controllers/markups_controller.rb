class MarkupsController < AuthenticatedController
  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def help
    render layout: false
  end

  # Returns the Textile version of a text passed as parameter
  def preview
    @text = params[:text]
    render layout: false
  end
end
