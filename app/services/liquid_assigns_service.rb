class LiquidAssignsService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def assigns
    result = project_assigns
    result.merge!(assigns_pro) if defined?(Dradis::Pro)
    result
  end

  private

  def assigns_pro
  end

  def project_assigns
    {
      'evidences' => cached_drops(project.evidence),
      'issues' => cached_drops(project.issues),
      'nodes' => cached_drops(project.nodes.user_nodes),
      'notes' => cached_drops(project.notes),
      'project' => ProjectDrop.new(project),
      'tags' => cached_drops(project.tags)
    }
  end

  def cached_drops(records)
    return [] if records.empty?

    type = records.first.class.to_s.underscore
    cache_key = "liquid-project-#{project.id}-#{type.pluralize}:#{records.maximum(:updated_at).to_i}-#{records.count}"
    drop_class = "#{type.camelize}Drop".constantize

    Rails.cache.fetch(cache_key) do
      records.map { |record| drop_class.new(record) }
    end
  end
end
