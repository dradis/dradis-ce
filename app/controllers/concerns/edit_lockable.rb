module EditLockable
  extend ActiveSupport::Concern

  protected

  def check_edit_lock(record)
    return if params[:force] == 'true'

    active_sessions = EditingSession.for_record(record).by_others(current_user)

    if active_sessions.any?
      @locked_by = active_sessions.includes(:user).map(&:user)
      @locked_record = record
      @back_path = request.referer || root_path
      render 'shared/edit_locked'
    end
  end

  def acquire_edit_session(record)
    attrs = {
      user: current_user,
      record_type: record.class.name,
      record_id: record.id
    }

    EditingSession.create!(attrs)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    EditingSession.find_by!(attrs)
  end

  def release_edit_session(record)
    EditingSession.where(
      user: current_user,
      record_type: record.class.name,
      record_id: record.id
    ).destroy_all
  end
end
