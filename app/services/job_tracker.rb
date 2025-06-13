class JobTracker
  VALID_STATE_KEYS = [:message, :state].freeze

  attr_accessor :job_id, :queue_name

  def initialize(job_id:, queue_name:)
    raise 'Missing job identifiers!' unless job_id && queue_name

    @job_id = job_id
    @queue_name = queue_name

    redis.expire(redis_key, 1.day.in_seconds)
  end

  def state
    state_hash = JSON.parse(redis.get(redis_key) || '{}')
    state_hash.symbolize_keys
  end

  def state=(state_hash)
    return unless valid_keys?(state_hash)

    redis.set(redis_key, state_hash.to_json, keepttl: true)
  end

  def update_state(new_state)
    state_hash = self.state
    self.state = state_hash.merge(new_state)
  end

  private

  def redis
    Resque.redis
  end

  def redis_key
    "#{queue_name}.#{job_id}"
  end

  def valid_keys?(hash)
    (hash.keys - VALID_STATE_KEYS).empty?
  end
end
