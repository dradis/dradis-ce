class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def check_unread
    if current_user.notifications.unread.any?
      NotificationsChannel.broadcast_to(current_user, {})
    end
  end
end
