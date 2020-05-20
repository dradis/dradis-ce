class MarkupController < AuthenticatedController
  layout false

  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def help
  end

  # Returns the Textile version of a text passed as parameter
  def preview
    @text = params[:text]
  end
end
