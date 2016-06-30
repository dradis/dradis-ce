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

  def render_revision_object_icon(revision_object,object_type=nil)
    object_type = revision_object_type(revision,revision_object) if object_type.nil?
    # Set icon css depending on object type.
    icon_css = %w{fa}
    icon_css << case object_type
                when 'Evidence'
                  'fa-flag'
                when 'Issue'
                  'fa-bug'
                when 'Note'
                  'fa-file-text-o'
                else
                  ''
                end
    content_tag(:i, '', class: icon_css)
  end

  def render_revision_object_title(revision_object)
    # Get title or content first characters.
    if revision_object.fields.empty?
      object_title = revision_object.respond_to?(:content) ? revision_object.content : revision_object.text
    else
      # Get title field, and if it's not set get first field value.
      object_title = revision_object.title? ? revision_object.title : revision_object.fields.values[0]
    end
    content_tag(:span, truncate(object_title, length: 25, separator: "..."), class: 'item-content')
  end

  def revision_object_type(revision,revision_object=nil)
    # If revision type is Note, check note's node id to determine object type.
    if revision.item_type == 'Note'
      revision_object = revision.reify if revision_object.nil?
      object_type = revision_object.node_id == Node.issue_library.id ? 'Issue' : 'Note'
    else
      object_type = revision.item_type
    end
  end

  def revision_object_location(revision_object,object_type)
    object_type = revision_object_type(revision,revision_object) if object_type.nil?
    # Get node if object is a Note or an Evidence.
    if ['Note','Evidence'].include?(object_type)
      if revision_object.node
        "at " + link_to(revision_object.node.label,revision_object.node)
      else
        'at a Node which has since been deleted'
      end
    else
      ''
    end
  end

  def render_revision_object_info(revision)
    revision_object = revision.reify
    object_type = revision_object_type(revision,revision_object)
    
    [
      render_revision_object_icon(revision_object,object_type),
      render_revision_object_title(revision_object),
      object_type.downcase,
      revision_object_location(revision_object,object_type),
    ].join(" ").html_safe
  end
end
