class DigestPresenter < NotificationPresenter
  attr_reader :current_project, :notifications, :template

  # Jul 9th at 2:45pm
  Time::DATE_FORMATS[:digest_format] = ->(time) { time.strftime "%h #{time.day.ordinalize} at %l:%M%P #{time.zone}" }

  def initialize(notifications, project, template)
    @current_project = project
    @notifications = notifications
    @template = template
  end

  def avatar_with_link(opts)
    h.link_to(avatar_image(notification.actor, opts), 'javascript:void(0)')
  end

  def comment_path(anchor: false)
    anchor = dom_id(notification.notifiable) if anchor
    polymorphic_url(
      path_to_comment,
      anchor: anchor
    )
  end

  def created_at
    notification.created_at.localtime.to_s(:digest_format)
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
        h.content_tag :span, notification.actor.email, style: 'font-weight: 600;'
      else
        'A user who has since been deleted'
      end
    else
      h.content_tag :span, "#{notification.actor.email} and #{pluralize(actor_count - 1, 'other')}", style: 'font-weight: 600;'
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
