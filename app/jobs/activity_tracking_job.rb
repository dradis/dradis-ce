class ActivityTrackingJob < ApplicationJob
  include ActivityTracking

  queue_as :dradis_project

  def perform(trackable:, action: , user:)
    track_activity(trackable, action, user)
  end
end
