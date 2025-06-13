module Tracked
  extend ActiveSupport::Concern

  included do
    before_enqueue :track_queued
    around_perform :track_pending
  end

  def tracker
    @tracker ||= JobTracker.new(job_id: job_id, queue_name: queue_name)
  end

  def track_pending
    tracker.update_state(state: :pending)
    yield
    unless tracker.state[:state] == :failed
      tracker.update_state(state: :completed)
    end
  end

  def track_queued
    tracker.update_state(state: :queued)
  end
end
