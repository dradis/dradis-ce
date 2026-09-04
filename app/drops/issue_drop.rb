class IssueDrop < BaseDrop
  include EscapedFields

  delegate :author, :state, :text, :title, to: :@record

  def initialize(record, scope = :all)
    super(record)
    @scope = scope
  end

  def affected
    @affected ||= scoped_evidence.includes(:node).map { |evidence| NodeDrop.new(evidence.node, @scope) }
  end

  def evidence
    scoped_evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def tags
    @tags ||= @record.tags.map { |tag| TagDrop.new(tag, @scope) }
  end

  ActiveSupport.run_load_hooks(:issue_drop, self)

  private

  # The Issue itself is expected to already match :scope (the caller is
  # responsible for that), so only its Evidence needs to be checked here.
  def scoped_evidence
    @record.evidence.public_send(@scope)
  end
end
