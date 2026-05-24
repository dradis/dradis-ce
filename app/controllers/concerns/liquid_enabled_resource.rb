module LiquidEnabledResource
  extend ActiveSupport::Concern

  included do
    around_action :liquid_render_context
    helper_method :liquid_assigns
  end

  def liquid_assigns
    # allows liquid_resource_assigns to be set even without project-level assigns
    @liquid_assigns ||= begin
      base = default_liquid_assigns
      extra = liquid_resource_assigns
      return nil if base.nil? && extra.empty?
      (base || {}).merge!(extra)
    end
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
    project_assigns if params[:project_id]
  end

  def project_assigns
    # This is required because we may be in Markup#preview that's passing
    # :project_id for Hera rendered editors
    project = Project.find(params[:project_id])
    authorize! :use, project

    LiquidCachedAssigns.new(project: project)
  end
end
