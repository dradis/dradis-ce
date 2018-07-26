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
    trackable.notifications.each do |notification|
      NotificationsChannel.broadcast_to(notification.recipient, {})
    end
  end
end
