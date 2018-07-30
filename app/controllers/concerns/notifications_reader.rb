module NotificationsReader
  protected

  def read_item_notifications(commentable, user)
    NotificationsReaderJob.perform_later(
      commentable_id: commentable.id,
      commentable_type: commentable.class.to_s,
      user_id: user.id
    )
  end
end
