class EventTrackingJob < ApplicationJob
  queue_as :dradis_project

  def perform(event_name:, properties: {})
    ahoy = Ahoy::Tracker.new
    ahoy.track(event_name, properties)
  end
end
