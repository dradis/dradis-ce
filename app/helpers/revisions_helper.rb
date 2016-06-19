module RevisionsHelper

  def record_revisions_path(record)
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue'
    case record
    when Issue
      issue_revisions_path(record)
    when Note
      node_note_revisions_path(record.node, record)
    when Evidence
      node_evidence_revisions_path(record.node, record)
    end
  end

  def record_revision_path(record, revision)
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue'
    case record
    when Issue
      issue_revision_path(record, revision)
    when Note
      node_note_revision_path(record.node, record, revision)
    when Evidence
      node_evidence_revision_path(record.node, record, revision)
    end
  end

end
