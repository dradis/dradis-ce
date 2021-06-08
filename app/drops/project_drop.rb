class ProjectDrop < Liquid::Drop
  def initialize(project)
    @project = project
  end

  def name
    @project.name
  end
end
