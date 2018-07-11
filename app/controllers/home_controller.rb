class HomeController < AuthenticatedController
  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def markup_help
    render layout: false
  end
  
  # Returns the Textile version of a text passed as parameter
  def textilize
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.json
    end
  end
end
