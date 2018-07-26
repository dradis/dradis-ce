module NotificationsReader
  protected

  # Mark each notifications associated with the item as read
  def read_item_notifications(item)
    NotificationsReaderJob.perform_later(
      notification_ids: notifications_by_commentable(item).pluck(:id)
    )
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
