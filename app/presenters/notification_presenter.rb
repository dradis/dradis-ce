class NotificationPresenter < BasePresenter
  presents :notification

  def avatar_with_link(size)
    h.link_to(avatar_image(size), 'javascript:void(0)')
  end

  def comment_path(anchor: false)
    anchor = dom_id(notification.notifiable) if anchor
    polymorphic_path(
      path_to_comment,
      anchor: anchor
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

  def avatar_image(size)
    if notification.actor
      h.image_tag(
        image_path('profile.jpg'),
        alt: notification.actor.email,
        class: 'gravatar',
        data: { fallback_image: image_path('logo_small.png') },
        style: "width: #{size}px; height: #{size}px",
        title: notification.actor.email,
        width: size
      )
    else
      h.image_tag 'logo_small.png', width: size, alt: 'This user has been deleted from the system'
    end
  end

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
