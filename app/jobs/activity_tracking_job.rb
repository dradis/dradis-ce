class ActivityTrackingJob < ApplicationJob
  queue_as :dradis_project

  def perform(action:, trackable_id:, trackable_type:, user_id:)
    user = User.find(user_id)
    trackable = trackable_type.constantize.find_by(id: trackable_id)

    Activity.create!(
      action:    action.to_s,
      trackable_id: trackable_id,
      trackable_type: trackable_type,
      user:      user
    )

    ActiveSupport::Notifications.instrument(
      'activity',
      action: action,
      trackable: trackable,
      user: user.email
    )
  end
end
