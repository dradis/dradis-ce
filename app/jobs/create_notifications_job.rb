class CreateNotificationsJob < ApplicationJob
  include ActivityTracking

  queue_as :dradis_project

  def perform(item)
    item.subscriptions.each do |s|
      Notification.create(
        actor: item.user,
        recipient: s.user,
        notifiable: item
      )
    end
  end
end
