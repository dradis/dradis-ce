class RecoverableRevisionPresenter < BasePresenter
  delegate :type, to: :recoverable_revision
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
      truncated_title,
      type.downcase,
      location,
    ].join(" ").html_safe
  end

  def title
    title =
      if trashed_object.is_a?(Note) && trashed_object.node == project.methodology_library
        note = trashed_object
        Methodology.new(filename: note.id, content: note.text).name
      elsif trashed_object.is_a?(Card)
        trashed_object.name
      else
        trashed_object.title
      end
  end

  private

  def icon
    # Set icon css depending on object type.
    icon_css = %w{fa}
    icon_css << case type
                when 'Card'
                  'fa-list-alt'
                when 'Evidence'
                  'fa-flag'
                when 'Issue'
                  'fa-bug'
                when 'Note'
                  'fa-file-text-o'
                when 'Methodology'
                  'fa-check'
                else
                  ''
                end
    h.content_tag(:i, '', class: icon_css)
  end

  def location
    result = ''
    # Get node if object is a Note or an Evidence.
    if ['Note','Evidence'].include?(type)
      if type == 'Evidence'
        unless trashed_object.issue
          result << ' for an issue which has since been deleted '
        end
      end
      if (node = trashed_object.node)
        result << 'at ' + h.link_to(node.label, [node.project, node])
      else
        result << 'at a node which has since been deleted'
      end
    elsif 'Card' == type
      board = recoverable_revision.associated_board
      board_name = board ? board.name : '[deleted]'
      result << " from the board #{board_name}"

      if board
        list = trashed_object.list
        list_name = list ? list.name : '[deleted]'
        result << " from the list #{list_name}"
      end
    end
    result
  end

  def truncated_title
    truncated_title = h.truncate(title, length: 25, separator: '...')
    h.content_tag(:span, truncated_title, class: 'item-content')
  end

  def trashed_object
    @trashed_object ||= revision.reify
  end

  def revision
    @revision ||= recoverable_revision.version
  end

  def project
    h.current_project
  end
end
