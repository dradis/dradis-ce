class HomeController < ProjectScopedController
  skip_before_action :set_current_project, only: [:markup_help, :textilize]

  def index
    redirect_to project_path(id: 1)
  end

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
