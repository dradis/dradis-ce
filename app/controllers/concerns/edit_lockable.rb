module EditLockable
  extend ActiveSupport::Concern

  protected

  def check_edit_lock(record)
    # The session is acquired before we look for competitors, not after,
    # so two requests arriving at the same time both get a row and the
    # id tiebreaker below can decide between them. Checking first and
    # acquiring second would leave a window where both requests see an
    # empty lock and both proceed.
    editing_session = acquire_edit_session(record)
    return if params[:force] == 'true'

    # Only sessions created before ours count as competing. The row id acts
    # as a deterministic tiebreaker so that when two requests race, exactly
    # one of them ends up with the lock and the other renders the lockout
    # screen, instead of both or neither.
    competing_sessions = EditingSession.for_record(record)
                                       .active
                                       .by_others(current_user)
                                       .where('id < ?', editing_session.id)

    return if competing_sessions.none?

    editing_session.destroy
    @locked_by = competing_sessions.includes(:user).map(&:user)
    @locked_record = record
    @back_path = url_from(request.referer) || root_path
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
    EditingSession.for_record(record).where(user: current_user).destroy_all
  end
end
