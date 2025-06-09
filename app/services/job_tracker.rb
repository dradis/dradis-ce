class JobTracker
  VALID_STATE_KEYS = [:message, :state].freeze
  DAY_IN_SECONDS = 86_400

  attr_accessor :job_id, :queue_name

  def initialize(job_id:, queue_name:)
    raise 'Missing job identifiers!' unless job_id && queue_name

    @job_id = job_id
    @queue_name = queue_name

    redis.expire(redis_key, DAY_IN_SECONDS)
  end

  def get_state
    state_hash = JSON.parse(redis.get(redis_key) || '{}')
    state_hash.symbolize_keys
  end

  def set_state(state_hash)
    return unless valid_keys?(state_hash)

    redis.set(redis_key, state_hash.to_json, keepttl: true)
  end

  def update_state(state)
    state_hash = get_state
    set_state(state_hash.merge(state))
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
