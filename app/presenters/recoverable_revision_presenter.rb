class RecoverableRevisionPresenter < BasePresenter
  presents :recoverable_revision

  def created_at_ago
    h.local_time_ago(revision.created_at)
  end

  def whodunnit
    revision.whodunnit
  end

  def info
    [
      icon,
      title,
      type.downcase,
      location,
    ].join(" ").html_safe
  end

  private

  def icon
    # Set icon css depending on object type.
    icon_css = %w{fa}
    icon_css << case type
                when 'Evidence'
                  'fa-flag'
                when 'Issue'
                  'fa-bug'
                when 'Note'
                  'fa-file-text-o'
                else
                  ''
                end
    h.content_tag(:i, '', class: icon_css)
  end

  def location
    result = ""
    # Get node if object is a Note or an Evidence.
    if ['Note','Evidence'].include?(type)
      if type == "Evidence"
        if trashed_object.issue
          result << " for #{trashed_object.issue.title} issue "
        else
          result << " for an issue which has since been deleted "
        end
      end
      if trashed_object.node
        result << "at " + h.link_to(trashed_object.node.label, trashed_object.node)
      else
        result << 'at a node which has since been deleted'
      end
    end
    result
  end

  def title
    truncated_title = h.truncate(trashed_object.title, length: 25, separator: "...")
    h.content_tag(:span, truncated_title, class: 'item-content')
  end

  def trashed_object
    @trashed_object ||= revision.reify
  end

  def revision
    @revision ||= recoverable_revision.version
  end

  def type
    # If revision type is Note, check note's node id to determine object type.
    # FIXME - ISSUE/NOTE INHERITANCE
    if revision.item_type == 'Note' && trashed_object.node_id == Node.issue_library.id
      'Issue'
    else
      revision.item_type
    end
  end

end
