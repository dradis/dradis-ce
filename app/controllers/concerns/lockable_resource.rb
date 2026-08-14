module LockableResource
  extend ActiveSupport::Concern

  protected

  def acquire_edit_session(record)
    EditingSession.acquire!(record_type: record.class.name, record_id: record.id, user: current_user)
  end

  def check_edit_lock
    competing_sessions = EditingSession.for_record(lockable_record).active.by_others(current_user).includes(:user)

    if competing_sessions.any? && params[:force] != 'true'
      @locked_by = competing_sessions.map(&:user)
      # Make the record accessible in the view
      @locked_record = lockable_record
      render 'shared/edit_locked'
      return
    end

    acquire_edit_session(lockable_record)
  end

  # Controllers that lock a record must return it here.
  def lockable_record
    raise NotImplementedError, "#{self.class.name} must implement #lockable_record"
  end

  def release_edit_session(record)
    EditingSession.for_record(record).where(user: current_user).destroy_all
  end
end
