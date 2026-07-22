module EditLockable
  extend ActiveSupport::Concern

  protected

  def acquire_edit_session(record)
    EditingSession.acquire(record_type: record.class.name, record_id: record.id, user: current_user)
  end

  def check_edit_lock
    record = lockable_record
    competing_sessions = EditingSession.for_record(record).active.by_others(current_user)

    if competing_sessions.any? && params[:force] != 'true'
      @locked_by = competing_sessions.includes(:user).map(&:user)
      @locked_record = record
      @back_path = url_from(request.referer) || root_path
      render 'shared/edit_locked'
      return
    end

    acquire_edit_session(record)
  end

  def lockable_record
    @lockable_record ||=
      instance_variable_get("@#{controller_name.singularize}") ||
        send("set_or_initialize_#{controller_name.singularize}")
  end

  def release_edit_session(record)
    EditingSession.for_record(record).where(user: current_user).destroy_all
  end
end
