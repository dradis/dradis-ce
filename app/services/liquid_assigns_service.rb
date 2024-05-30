class LiquidAssignsService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def assigns
    result = project_drops
    result.merge!(assigns_pro) if defined?(Dradis::Pro)
    result
  end

  private

  def assigns_pro
  end

  def project_drops
    {
      'evidence' => project_records(type: :evidence),
      'issues' => project_records(type: :issue),
      'nodes' => project_records(type: :node),
      'notes' => project_records(type: :note),
      'project' => ProjectDrop.new(project),
      'tags' => project_records(type: :tag)
    }
  end

  def project_records(type:)
    records = project.send(type.to_s.pluralize)
    records = records.user_nodes if type == :node

    cache_key = "liquid-project-#{type.to_s.pluralize}#{records.maximum(:updated_at)}/#{records.pluck(:id).join('-')}"
    drop_class = "#{type.to_s.capitalize}Drop".constantize

    Rails.cache.fetch(cache_key) do
      records.map { |record| drop_class.new(record) }
    end
  end
end
