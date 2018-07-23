module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
  end

  def create_notifications(action:, recipients:)
    ActiveRecord::Base.transaction do
      recipients.each do |recipient|
        notification = Notification.create(
          action: action,
          actor: user,
          notifiable: self,
          recipient: recipient
        )

        broadcast_to_user(notification, user)
      end
    end
  end

  def broadcast_to_user(notification, user)
    project = self.commentable.node.project
    notification_html = NotificationsController.render(
      partial: 'notifications/item',
      locals: { notification: notification, notification_project: project}
    )
    NotificationsChannel.broadcast_to(user, notification_html: notification_html)
  end
end
