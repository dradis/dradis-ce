class NotificationsBroadcastingJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, notifiable_id:, notifiable_type:, user_id:, recipient_ids: [])
    notifiable = notifiable_type.constantize.find_by(id: notifiable_id)

    if notifiable.respond_to?(:notify)
      notifiable.notify(
        action: action,
        actor: User.find(user_id),
        recipients: User.where(id: recipient_ids)
      )

      notifiable.notifications.each do |notification|
        NotificationsChannel.broadcast_to(notification.recipient, {})
      end
    end
  end
end
