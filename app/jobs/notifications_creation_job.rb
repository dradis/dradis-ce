class NotificationsCreationJob < ApplicationJob
  queue_as :dradis_project

  def perform(notifiable:, action: , user:)
    notifiable.subscriptions.each do |subscription|
      Notification.create!(
        action: action,
        actor: user,
        notifiable: notifiable,
        recipient: subscription.user
      )
    end
  end
end
