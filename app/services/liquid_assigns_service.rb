class LiquidAssignsService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def assigns
    result = {}
    result['project'] = ProjectDrop.new(project)
    result['issues'] = project.issues.map { |issue| IssueDrop.new(issue) }
    result['nodes'] = project.nodes.user_nodes.map { |node| NodeDrop.new(node) }
    result['evidences'] = project.evidence.map { |evidence| EvidenceDrop.new(evidence) }
    result['tags'] = project.tags.map { |tag| TagDrop.new(tag) }

    result
  end
end
