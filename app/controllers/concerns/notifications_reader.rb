module NotificationsReader
  protected

  # Mark each notifications associated with the item as read
  def read_item_notifications(item)
    Notification.transaction do
      notifications =
        notifications_by_commentable(item).unread.where(recipient: current_user)
      notifications.update_all(read_at: Time.now)
    end

    # Re-set the notifications alert dot
    @has_unread_notifications = current_user.notifications.unread.any?
  end

  def notifications_by_commentable(commentable)
    Notification.
      joins('INNER JOIN comments ON notifications.notifiable_id = comments.id').
      where(notifiable_type: 'Comment').
      where(
        'comments.commentable_type = ? AND comments.commentable_id = ?',
        commentable.class.to_s,
        commentable.id
      )
  end
end
