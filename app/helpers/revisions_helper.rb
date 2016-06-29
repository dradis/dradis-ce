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

  def link_to_conflicting_revision(record, revision)
    time = revision.created_at.strftime("%b %e %Y, %-l:%M%P")
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

  # Renders revision item type and icon.
  def render_revision_type(revision)
    # If revision type is Note, check note's node id to determine object type.
    if revision.item_type == 'Note'
      note = revision.reify
      item_type = note.node_id == Node.issue_library.id ? 'Issue' : 'Note'
    else
      item_type = revision.item_type
    end
    # Set icon css depending on item type.
    icon_css = %w{fa}
    icon_css << case item_type
                when 'Evidence'
                  'fa-flag'
                when 'Issue'
                  'fa-bug'
                when 'Note'
                  'fa-file-text-o'
                else
                  ''
                end
    content_tag(:i, '', class: icon_css) + " " + item_type
  end
end
