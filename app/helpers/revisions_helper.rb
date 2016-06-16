module RevisionsHelper

  def record_revision_path(record, revision)
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue'
    case record
    when Issue
      issue_revision_path(record, revision)
    when Note
      note_revision_path(revision)
    when Evidence
      node_evidence_revision_path(record.node, record, revision)
    end
  end

  def note_revision_path(revision)
    note = revision.item
    node_note_revision_path(note.node, note, revision)
  end

end
