module RevisionsHelper
  # Use %-d (non-padded) rather than %e (zero-padded) for the day of the month,
  # or the specs will fail when they're run between the 1st and the 9th of
  # any month (because the specs will look for e.g. "Jul  9", with two spaces,
  # but the whitespace in the browser will be collapsed so the actual page
  # will say "Jul 9" with one space.)
  DATE_FORMAT = "%b %-d %Y, %-l:%M%P"

  def record_revisions_path(record)
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue' FIXME - ISSUE/NOTE INHERITANCE
    case record
    when Issue
      project_issue_revisions_path(@project, record)
    when Note
      project_node_note_revisions_path(@project, record.node, record)
    when Evidence
      project_node_evidence_revisions_path(@project, record.node, record)
    end
  end

  def record_revision_path(record, revision)
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue' FIXME - ISSUE/NOTE INHERITANCE
    case record
    when Issue
      project_issue_revision_path(@project, record, revision)
    when Note
      project_node_note_revision_path(@project, record.node, record, revision)
    when Evidence
      project_node_evidence_revision_path(@project, record.node, record, revision)
    end
  end

  def link_to_conflicting_revision(record, revision)
    time = revision.created_at.strftime(DATE_FORMAT)
    text =  if revision.whodunnit
              if revision.whodunnit == user_for_paper_trail
                "Your update at #{time}"
              else
                "Update by #{revision.whodunnit} at #{time}"
              end
            else
              "Update by unknown user at #{time}"
            end
    link_to text, record_revision_path(record, revision)
  end

end
