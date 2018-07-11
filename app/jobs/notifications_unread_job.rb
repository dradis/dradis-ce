class NotificationsUnreadJob < ApplicationJob
  queue_as :dradis_project

  def perform(subscription_ids:)
    subscriptions = Subscription.where(id: subscription_ids)
    subscriptions.each do |subscription|
      NotificationChannel.broadcast_to(subscription.user, 'ping')
    end
  end
end
