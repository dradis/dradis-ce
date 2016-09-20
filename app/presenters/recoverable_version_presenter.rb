class RecoverableVersionPresenter < BasePresenter
  presents :recoverable_version

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
    # Get node if object is a Note or an Evidence.
    if ['Note','Evidence'].include?(type)
      if trashed_object.node
        "at " + h.link_to(trashed_object.node.label, trashed_object.node)
      else
        'at a Node which has since been deleted'
      end
    else
      ''
    end
  end

  def title
    # Get title or content first characters.
    if trashed_object.fields.empty?
      title_text = trashed_object.respond_to?(:content) ? trashed_object.content : trashed_object.text
    else
      # Get title field, and if it's not set get first field value.
      title_text = trashed_object.title? ? trashed_object.title : trashed_object.fields.values[0]
    end
    truncated_title = h.truncate(title_text, length: 25, separator: "...")
    h.content_tag(:span, truncated_title, class: 'item-content')
  end

  def trashed_object
    @trashed_object ||= revision.reify
  end

  def revision
    @revision ||= recoverable_version.version
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
