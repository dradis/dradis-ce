class LiquidCachedAssigns < Hash
  AVAILABLE_PROJECT_ASSIGNS = %w{ evidences issues nodes notes project tags }.freeze

  attr_accessor :assigns, :project

  def initialize(project:)
    @assigns = { 'project' => ProjectDrop.new(@project) }
    @project = project
  end

  def [](record_type)
    return unless AVAILABLE_PROJECT_ASSIGNS.include?(record_type)

    if assigns[record_type]
      assigns[record_type]
    else
      assigns[record_type] = cached_drops(record_type)
    end
  end

  def inspect
    assigns.inspect
  end

  def key?(msg)
    AVAILABLE_PROJECT_ASSIGNS.include?(msg.to_s)
  end

  def respond_to?(msg)
    return true if key?(msg)
    super(msg)
  end

  private

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
