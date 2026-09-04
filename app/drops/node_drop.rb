class NodeDrop < BaseDrop
  delegate :label, to: :@record

  def initialize(record, scope = :all)
    super(record)
    @scope = scope
  end

  def evidence
    @evidence ||= scoped_evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def notes
    @notes ||= @record.notes.map { |note| NoteDrop.new(note) }
  end

  private

  # A Node doesn't know whether the Issue its Evidence belongs to matches
  # :scope, so both the Evidence and its Issue need to be checked.
  def scoped_evidence
    @record.evidence.public_send(@scope).joins(:issue).merge(Issue.public_send(@scope))
  end
end
