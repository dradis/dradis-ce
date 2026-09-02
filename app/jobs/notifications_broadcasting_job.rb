class NotificationsBroadcastingJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, notifiable_id:, notifiable_type:, recipient_ids: [], user_id: nil)
    notifiable = notifiable_type.constantize.find_by(id: notifiable_id)
    return unless notifiable.respond_to?(:notify)

    recipients = User.where(id: recipient_ids)

    if user_id
      notifiable.notify(action: action, actor: User.find(user_id), recipients: recipients)
    else
      # No actor was given, so each recipient is notified as their own actor.
      recipients.each do |recipient|
        notifiable.notify(action: action, actor: recipient, recipients: [recipient])
      end
    end

    notifiable.notifications.each do |notification|
      NotificationsChannel.broadcast_to(notification.recipient, {})
    end
  end
end
