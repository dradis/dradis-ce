module LiquidEnabledResource
  extend ActiveSupport::Concern

  included do
    around_action :liquid_render_context
    helper_method :liquid_assigns
  end

  def liquid_assigns
    @liquid_assigns ||= default_liquid_assigns.merge!(liquid_resource_assigns)
  end

  # To be overwritten by each controller
  def liquid_resource_assigns
    {}
  end

  def preview
    @text = params[:text]
    render 'markup/preview', layout: false
  end

  # Makes Liquid assigns available to HasFields#fields for the duration of the request,
  # so field values are rendered as Liquid templates. 
  # `around_action` ensures cleanup via ensure even when the action raises
  # The proc defers liquid_assigns evaluation until first use, after all before_actions
  # have run and liquid_resource_assigns has had a chance to merge in resource-specific assigns.
  def liquid_render_context
    LiquidRenderContext.set(-> { liquid_assigns })
    yield
  ensure
    LiquidRenderContext.clear
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
    # This is required because we may be in Markup#preview that's passing
    # :project_id for Hera rendered editors
    project = Project.find(params[:project_id])
    authorize! :use, project

    LiquidCachedAssigns.new(project: project)
  end
end
