class NodeDrop < BaseDrop
  delegate :label, to: :@record

  def evidence
    @evidence ||= @record.evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def notes
    @notes ||= @record.notes.map { |note| NoteDrop.new(note) }
  end
end
