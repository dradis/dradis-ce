class ActivityTrackingJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, trackable_id:, trackable_type:, user_id:)
    user = User.find(user_id)
    
    trackable = trackable_type.constantize.find_by(id: trackable_id)

    Activity.create!(
      action:    action.to_s,
      trackable_id: trackable_id,
      trackable_type: trackable_type,
      user:      user.email
    )

    ActiveSupport::Notifications.instrument(
      'activity',
      action: action,
      trackable: trackable,
      user: user.email
    )

    if trackable.respond_to?(:notify)
      trackable.notify(action)
      broadcast_notifications(trackable)
    end
  end

  private

  def broadcast_notifications(trackable)
    project = trackable.commentable.project

    trackable.notifications.each do |notification|
      notification_html = NotificationsController.render(
        partial: 'notifications/notification',
        locals: { notification: notification, notification_project: project }
      )

      NotificationsChannel.broadcast_to(
        notification.recipient,
        notification_html: notification_html
      )
    end
  end
end
