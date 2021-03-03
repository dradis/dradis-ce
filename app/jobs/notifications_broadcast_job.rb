class NotificationsBroadcastJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, actor_id:, notifiable_id:, notifiable_type:, data: {})
    notifiable = notifiable_type.constantize.find_by(id: notifiable_id)

    if notifiable.respond_to?(:notify)
      notifiable.notify(action: action, actor: User.find(actor_id), data: data)

      notifiable.notifications.each do |notification|
        NotificationsChannel.broadcast_to(notification.recipient, {})
      end
    end
  end
end
