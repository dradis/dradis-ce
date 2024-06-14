class LiquidAssignsService
  attr_accessor :project

  def initialize(project:)
    @project = project
  end

  def assigns
    LiquidCachedAssigns.new(project: project)
  end

  private

  def assigns_pro
  end
end
