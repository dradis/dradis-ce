module EditingLock
  LOCK_TTL = 120

  def self.included(base)
    base.before_action :set_editing_lock_record, only: [:lock, :unlock]
  end

  # Controllers must implement this to return the relevant record.
  def editing_lock_record
    raise NotImplementedError, "#{self.class} must implement #editing_lock_record"
  end

  def lock
    if renew_lock(@editing_lock_record)
      head :ok
    else
      render json: lock_owner(@editing_lock_record), status: :conflict
    end
  end

  def unlock
    release_lock(@editing_lock_record)
    head :no_content
  end

  protected

  # Acquires the lock for the current user.
  #
  # Returns true if the lock was acquired (or already held by this user).
  # Returns false if another user holds the lock.
  def acquire_lock(record)
    key = lock_key(record)
    existing = redis.get(key)

    if existing
      data = JSON.parse(existing)
      if data['user_id'] == current_user.id
        redis.expire(key, LOCK_TTL)
        return true
      else
        return false
      end
    end

    set_lock(key)
    true
  end

  # Acquires the lock regardless of who currently holds it.
  # The displaced user will discover the takeover on their next heartbeat.
  def force_lock(record)
    set_lock(lock_key(record))
  end

  # Releases the lock only if the current user holds it.
  def release_lock(record)
    key = lock_key(record)
    existing = redis.get(key)
    return unless existing

    data = JSON.parse(existing)
    redis.del(key) if data['user_id'] == current_user.id
  end

  # Renews the lock TTL if the current user holds it (used by heartbeat).
  #
  # Returns true if renewed, false if the lock belongs to another user or is gone.
  def renew_lock(record)
    key = lock_key(record)
    existing = redis.get(key)
    return false unless existing

    data = JSON.parse(existing)
    return false unless data['user_id'] == current_user.id

    redis.expire(key, LOCK_TTL)
    true
  end

  # Returns { 'user_id' => ..., 'user_name' => ... } or nil.
  def lock_owner(record)
    existing = redis.get(lock_key(record))
    JSON.parse(existing) if existing
  end

  def locked_by_other?(record)
    owner = lock_owner(record)
    owner && owner['user_id'] != current_user.id
  end

  private

  def set_editing_lock_record
    @editing_lock_record = editing_lock_record
  end

  def lock_key(record)
    model = record.model_name.name.downcase
    "editing:#{current_project.id}:#{model}:#{record.id}"
  end

  def set_lock(key)
    data = { user_id: current_user.id, user_name: current_user.name }.to_json
    redis.set(key, data, ex: LOCK_TTL)
  end

  def redis
    Resque.redis
  end
end
