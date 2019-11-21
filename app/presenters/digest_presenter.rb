class DigestPresenter < NotificationPresenter
  attr_reader :current_project, :notifications, :template

  def initialize(notifications, project, template)
    @current_project = project
    @notifications = notifications
    @template = template
  end

  def avatar_with_link(size)
    h.link_to(avatar_image(notification.actor, size: size, inline_onerror: true), 'javascript:void(0)')
  end

  def comment_path(anchor: false)
    anchor = dom_id(notification.notifiable) if anchor
    polymorphic_url(
      path_to_comment,
      anchor: anchor
    )
  end

  def created_at_ago
    # We can't use the local_time gem here because there's no JS
    "#{time_ago_in_words(notification.created_at)} ago"
  end

  def text_title
    email =
      if notification.actor
        notification.actor.email
      else
        'A user who has since been deleted'
      end

    [email, render_partial.strip].join(' ')
  end

  private

  def linked_email
    # Get the count of the unique list of actors from the list of notifications
    actor_count = notifications.pluck(:actor_id).uniq.compact.count

    if actor_count <= 1
      if notification.actor
        h.content_tag :span, notification.actor.email, class: 'user-name'
      else
        'A user who has since been deleted'
      end
    else
      h.content_tag :span, "#{notification.actor.email} and #{pluralize(actor_count - 1, 'other')}", class: 'user-name'
    end
  end

  def notification
    @notification ||=
      if notifications.count > 1
        # Get the first notification with an existing actor
        notifications.find(&:actor)
      else
        notifications.first
      end
  end
end
