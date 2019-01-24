class NotificationsReaderJob < ApplicationJob
  queue_as :dradis_project

  # Mark each notifications associated with the item as read
  def perform(commentable_id:, commentable_type:, user_id:)
    Notification.transaction do
      notifications_by_commentable(id: commentable_id, type: commentable_type).
        unread.
        where(recipient_id: user_id).
        mark_all_as_read!

      if Notification.unread.where(recipient_id: user_id).count == 0
        NotificationsChannel.broadcast_to(User.find(user_id), 'all_read')
      end
    end
  end

  private

  def notifications_by_commentable(id:, type:)
    Notification.
      joins('INNER JOIN comments ON notifications.notifiable_id = comments.id').
      where(notifiable_type: 'Comment').
      where(
        'comments.commentable_type = ? AND comments.commentable_id = ?',
        type,
        id
      )
  end
end
