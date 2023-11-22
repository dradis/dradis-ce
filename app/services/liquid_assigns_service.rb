class LiquidAssignsService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def assigns
    result = {}
    result['project'] = ProjectDrop.new(project)

    if defined?(Dradis::Pro)
      result['document_properties'] = DocumentPropertiesDrop.new(properties: project.content_library.properties)
      result['team'] = TeamDrop.new(project.team)
    end

    result
  end
end
