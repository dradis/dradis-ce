class LiquidCachedAssigns < Hash
  AVAILABLE_PROJECT_ASSIGNS = %w{ evidences issues nodes notes project tags }.freeze

  attr_accessor :assigns, :project

  def initialize(project:)
    @assigns = { 'project' => ProjectDrop.new(project) }
    @assigns.merge!(assigns_pro)

    @project = project
  end

  def [](record_type)
    assigns[record_type] ||= cached_drops(record_type)
  end

  def key?(key)
    AVAILABLE_PROJECT_ASSIGNS.include?(key.to_s) || assigns.key?(key)
  end

  def merge!(hash)
    @assigns.merge!(hash)
    self
  end

  private

  def assigns_pro
    {}
  end

  def cached_drops(record_type)
    records = project_records(record_type)

    return [] if records.empty?

    cache_key = ActiveSupport::Cache.expand_cache_key([project.id, records], 'liquid')
    drop_class = "#{record_type.singularize.camelize}Drop".constantize

    Rails.cache.fetch(cache_key) do
      records.map { |record| drop_class.new(record) }
    end
  end

  def project_records(record_type)
    return [] unless AVAILABLE_PROJECT_ASSIGNS.include?(record_type)

    case record_type
    when 'evidences'
      project.evidence
    when 'nodes'
      project.nodes.user_nodes
    else
      project.send(record_type.to_sym)
    end
  end
end
