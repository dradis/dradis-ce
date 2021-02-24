class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def check_unread(data)
    if current_user.notifications.unread.where(project_id: data['project_id']).any?
      NotificationsChannel.broadcast_to(current_user, {})
    end
  end
end
