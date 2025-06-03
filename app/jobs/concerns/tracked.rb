module Tracked
  extend ActiveSupport::Concern

  included do
    after_enqueue do |job|
      job.tracker.update_status(status: 'queued')
    end

    around_perform do |job, block|
      job.tracker.update_status(status: 'pending')
      block.call

      unless job.tracker.get_status[:status] == 'failed'
        job.tracker.update_status(status: 'completed')
      end
    end
  end

  def tracker
    @tracker ||= JobTracker.new(job_id: job_id, queue_name: queue_name)
  end
end
