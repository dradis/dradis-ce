class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  before_perform do |job|
    ActiveRecord::Base.connection_handler.clear_active_connections!
  end

  after_enqueue do |job|
    job.tracker.update_status(status: 'queued')
  end

  around_perform do |job, block|
    job.tracker.update_status(status: 'pending')
    block.call
    job.tracker.update_status(status: 'completed')
  end

  def tracker
    @tracker ||= JobTracker.new(job_id: job_id, queue_name: queue_name)
  end
end
