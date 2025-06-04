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
    tracker.update_status(status: 'pending')
    yield
    unless tracker.get_status[:status] == 'failed'
      tracker.update_status(status: 'completed')
    end
  end

  def track_queued
    tracker.update_status(status: 'queued')
  end
end
