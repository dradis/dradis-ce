class NodeDrop < BaseDrop
  delegate :label, to: :@record

  def evidence
    @evidence ||= @record.evidence.filter_map do |evidence|
      EvidenceDrop.new(evidence) if evidence.issue.published?
    end
  end

  def notes
    @notes ||= @record.notes.map { |note| NoteDrop.new(note) }
  end
end
