class JobTracker
  attr_accessor :job_id, :queue_name

  def initialize(job_id:, queue_name:)
    @job_id = job_id
    @queue_name = queue_name
  end

  def get_status
    status_hash = JSON.parse(redis.get(redis_key) || '{}')
    status_hash.symbolize_keys
  end

  def set_status(status_hash)
    status_hash.symbolize_keys!
    redis.set(redis_key, status_hash.to_json)
  end

  def update_status(status)
    status_hash = get_status
    set_status(status_hash.merge(status))
  end

  private

  def redis
    Resque.redis
  end

  def redis_key
    "#{queue_name}.#{job_id}"
  end
end
