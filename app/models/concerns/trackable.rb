module Trackable
  extend ActiveSupport::Concern

  included do
    after_create  :track_created
    after_update  :track_updated
    after_destroy :track_destroyed
  end

  def track_activity(action)
    ActivityTrackingJob.perform_later(
      trackable: self,
      action: action.to_s,
      user: self.user
    )
  end

  def track_created
    track_activity(:create)
  end

  def track_updated
    track_activity(:update)
  end

  def track_destroyed
    track_activity(:destroy)
  end
end
