class ActivityTrackingJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, trackable_id:, trackable_type:, user:)
    trackable = trackable_type.constantize.find(trackable_id) rescue nil

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

    NotificationCreationService.new(
      action: action,
      actor: user,
      notifiable: trackable
    ).create_notifications
  end
end
