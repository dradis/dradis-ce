class NotificationPresenter < BasePresenter
  presents :notification

  def avatar_with_link(size)
    h.link_to(avatar_image(notification.actor, size: size), 'javascript:void(0)')
  end

  def comment_path(anchor: false)
    anchor = dom_id(notification.notifiable) if anchor
    polymorphic_path(
      path_to_comment,
      anchor: anchor
    )
  end

  def card_path
    card = notification.notifiable
    polymorphic_path(
      [current_project, card.board, card.list, card]
    )
  end

  def created_at_ago
    h.local_time_ago(notification.created_at)
  end

  def icon
    icon_css = %w{notification-icon fa fa-fw}
    icon_css << case notification.notifiable_type
                when 'Comment'
                  'fa-comment'
                when 'Card'
                  'fa-tasks'
                else
                  ''
                end
    h.content_tag :i, nil, class: icon_css
  end

  def render_title
    [
      linked_email,
      render_partial
    ].join(' ').html_safe
  end

  private

  # Interestingly enough we're not linking the email to anything yet as we
  # don't know what we should link to. For the time being lets just enclose
  # it in a strong tag.
  def linked_email
    if notification.actor
      # h.link_to(notification.actor.email, 'javascript:void(0);')
      h.content_tag :strong, notification.actor.email
    else
      'a user who has since been deleted'
    end
  end

  def render_partial
    locals = { presenter: self }
    locals[notification.notifiable_type.underscore.to_sym] = notification.notifiable
    render partial_path, locals
  end

  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for notification in #{partial_paths}")
  end

  def partial_paths
    ["notifications/#{notification.notifiable_type.underscore}"]
  end

  def path_to_comment
    # FIXME - ISSUE/NOTE INHERITANCE
    # Would like to use only `commentable.respond_to?(:node)` here, but
    # that would return a wrong path for issues
    comment         = notification.notifiable
    commentable     = comment.commentable

    if commentable.respond_to?(:node) && !commentable.is_a?(Issue)
      [current_project, commentable.node, commentable]
    elsif commentable.is_a?(Card)
      [current_project, commentable.board, commentable.list, commentable]
    else
      [current_project, commentable]
    end
  end
end
