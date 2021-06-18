class NodeDrop < BaseDrop
  delegate :label, to: :@record

  def evidence
    @evidence ||= @record.evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end
end
