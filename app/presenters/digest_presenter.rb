class DigestPresenter < NotificationPresenter
  attr_accessor :notifications, :template

  def initialize(notifications, template)
    @notifications = notifications
    @template = template
  end

  def comment_path(anchor: false)
    polymorphic_url(
      path_to_comment,
      anchor: anchor
    )
  end

  def created_at_ago
    # We can't use the local_time gem here because there's no JS
    "#{time_ago_in_words(notification.created_at)} ago"
  end

  private

  def avatar_image(size)
    if notification.actor
      h.image_tag(
        attachments['profile'].url,
        alt: notification.actor.email,
        class: 'gravatar',
        title: notification.actor.email,
        width: size,
        # Fallback image
        onerror: "this.src = '#{image_path('logo_small')}';"
      )
    else
      h.image_tag(
        attachments['logo_small'].url,
        width: size,
        alt: 'This user has been deleted from the system'
      )
    end
  end

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
        notifications.first(&:actor_id)
      else
        notifications.first
      end
  end

  def current_project
    @current_project ||= Project.new
  end
end
