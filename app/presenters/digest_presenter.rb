class DigestPresenter < NotificationPresenter
  def self.build_presenters(notifications, template)
    notifications.map do |_, item_notifications|
      DigestPresenter.new(item_notifications, template)
    end
  end

  attr_accessor :notifications, :template

  def initialize(notifications, template)
    @notifications = notifications
    @template = template
  end

  def comment_path(anchor: false)
    # FIXME - ISSUE/NOTE INHERITANCE
    # Would like to use only `commentable.respond_to?(:node)` here, but
    # that would return a wrong path for issues
    comment         = notification.notifiable
    commentable     = comment.commentable
    path_to_comment =
      if commentable.respond_to?(:node) && !commentable.is_a?(Issue)
        [current_project, commentable.node, commentable]
      elsif commentable.is_a?(Card)
        [current_project, commentable.board, commentable.list, commentable]
      else
        [current_project, commentable]
      end

    anchor = dom_id(comment) if anchor
    polymorphic_url(
      path_to_comment,
      anchor: anchor
    )
  end

  private

  def avatar_image(size)
    if notification.actor
      h.image_tag(
        attachments['profile'].url,
        alt: notification.actor.email,
        class: 'gravatar',
        data: { fallback_image: attachments['logo_small'].url },
        title: notification.actor.email,
        width: size
      )
    else
      h.image_tag 'logo_small.png', width: size, alt: 'This user has been deleted from the system'
    end
  end

  def linked_email
    if notifications.count > 1
      if notification.actor
        # h.link_to(notification.actor.email, 'javascript:void(0);')
        h.content_tag :strong, notification.actor.email
      else
        'a user who has since been deleted'
      end
    else
      count = notifications.pluck(:actor_id).uniq.count
      h.content_tag :strong, "#{notification.actor.email} and #{pluralize(count, 'other')}"
    end
  end

  def notification
    notifications.first
  end

  def current_project
    @current_project ||= Project.new
  end
end
