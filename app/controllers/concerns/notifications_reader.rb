module NotificationsReader
  extend ActiveSupport::Concern

  included do
    after_action :read_item_notifications, only: :show
  end

  protected

  def read_item_notifications
    commentable = instance_variable_get("@#{controller_name.singularize}")
    NotificationsReaderJob.perform_later(
      commentable_id: commentable.id,
      commentable_type: commentable.class.to_s,
      user_id: current_user.id
    )
  end
end
