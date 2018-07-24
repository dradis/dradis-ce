module NotificationsReader
  protected

  # Mark each notifications associated with the item as read
  def read_item_notifications(item)
    item.comments.each do |comment|
      comment.notifications.where(recipient: current_user, read_at: nil).each(&:read!)
    end

    # Re-set the notifications alert dot
    @has_unread_notifications = current_user.notifications.unread.any?
  end
end
