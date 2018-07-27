module NotificationsReader
  protected

  def read_item_notifications(commentable)
    NotificationsReaderJob.perform_later(
      commentable_id: commentable.id,
      commentable_type: commentable.class.to_s
    )
  end
end
