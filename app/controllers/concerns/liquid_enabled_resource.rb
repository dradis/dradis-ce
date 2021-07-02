module LiquidEnabledResource
  extend ActiveSupport::Concern

  included do
    helper_method :liquid_assigns
  end

  def liquid_assigns
    @liquid_assigns ||= default_liquid_assigns.merge!(liquid_resource_assigns)
  end

  # To be overwritten by each controller
  def liquid_resource_assigns
    raise 'Controller included LiquidEnabledResource without defining a liquid_resource_assigns'
  end

  private

  def default_liquid_assigns
    if params[:project_id]
      project_assigns
    else
      {}
    end
  end

  def project_assigns
    result = {}

    # This is required because we may be in Markup#preview that's passing
    # :project_id for Tylium rendered editors
    project = Project.find(params[:project_id])
    # authorize! :use, project

    result['project'] = ProjectDrop.new(project)

    result
  end
end
