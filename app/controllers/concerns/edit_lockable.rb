module EditLockable
  extend ActiveSupport::Concern

  protected

  def check_edit_lock(record)
    editing_session = acquire_edit_session(record)
    return if params[:force] == 'true'

    competing_sessions = EditingSession.for_record(record)
                                       .active
                                       .by_others(current_user)
                                       .where('id < ?', editing_session.id)

    return if competing_sessions.none?

    editing_session.destroy
    @locked_by = competing_sessions.includes(:user).map(&:user)
    @locked_record = record
    @back_path = request.referer || root_path
    render 'shared/edit_locked'
  end

  def acquire_edit_session(record)
    attrs = {
      user: current_user,
      record_type: record.class.name,
      record_id: record.id
    }

    EditingSession.purge_stale_for(record_type: attrs[:record_type], record_id: attrs[:record_id])
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
