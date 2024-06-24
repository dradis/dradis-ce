class LiquidCachedAssigns < Hash
  AVAILABLE_PROJECT_ASSIGNS = %w{ evidences issues nodes notes project tags }.freeze

  attr_accessor :assigns, :project

  def initialize(project:)
    @project = project

    @assigns = { 'project' => ProjectDrop.new(project) }
    @assigns.merge!(assigns_pro)
  end

  def [](record_type)
    assigns[record_type] ||= cached_drops(record_type)
  end

  # SEE: https://github.com/Shopify/liquid/blob/77bc56/lib/liquid/context.rb#L211
  # Liquid is checking if the variable is present in the assigns hash by
  # calling the `key?` method. Since we're lazily loading the keys, the variable
  # may not yet be present in the assigns hash.
  def key?(key)
    AVAILABLE_PROJECT_ASSIGNS.include?(key.to_s) || assigns.key?(key)
  end

  def merge(hash)
    LiquidCachedAssigns.new(project: project).merge!(@assigns.merge(hash))
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
    when 'notes'
      # FIXME - ISSUE/NOTE INHERITANCE
      project.notes.includes(:node).where.not(node: { type_id: Node::Types::ISSUELIB })
    else
      project.send(record_type.to_sym)
    end
  end
end
