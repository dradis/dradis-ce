class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    notification = Notification.find(params[:id])
    stream_for notification
  end
end
