class ActivityTrackingJob < ApplicationJob
  queue_as :dradis_project

  def track_activity(trackable, action, user)
    Activity.create!(
      trackable: trackable,
      user:      user.email,
      action:    action.to_s
    )

    ActiveSupport::Notifications.instrument(
      'activity',
      action: action,
      trackable: trackable,
      user: user.email
    )
  end

  def track_created(trackable, user)
    track_activity(trackable, :create, user)
  end

  def track_updated(trackable, user)
    track_activity(trackable, :update, user)
  end

  def track_destroyed(trackable, user)
    track_activity(trackable, :destroy, user)
  end

  def track_recovered(trackable, user)
    track_activity(trackable, :recover, user)
  end

  def perform(trackable:, action: , user:)
    track_activity(trackable, action, user)
  end
end
