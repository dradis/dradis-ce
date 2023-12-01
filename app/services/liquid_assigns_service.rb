class LiquidAssignsService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def assigns
    result = { 'project' => ProjectDrop.new(project) }
    result.merge!(assigns_pro) if defined?(Dradis::Pro)
    result
  end

  private

  def assigns_pro
  end
end
