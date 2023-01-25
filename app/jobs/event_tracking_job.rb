class EventTrackingJob < ApplicationJob
  queue_as :dradis_project

  def perform(visit:, event_name:, properties: {})
    ahoy = Ahoy::Tracker.new(visit_token: visit.visit_token)
    ahoy.track(event_name, properties)
  end
end
