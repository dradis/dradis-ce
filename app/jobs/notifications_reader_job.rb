class NotificationsReaderJob < ApplicationJob
  queue_as :dradis_project

  def perform(notification_ids:)
    Notification.transaction do
      Notification.where(id: notification_ids).update_all(read_at: Time.now)
    end
  end

end
