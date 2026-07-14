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

    # Only sessions created before ours count as competing. We compare by id
    # rather than started_at because started_at only has second-level
    # precision on SQLite's CURRENT_TIMESTAMP, so two racing requests in the
    # same second would tie and neither would come out ahead. The id is
    # unique and strictly increases with insertion order on every supported
    # database, so it always breaks the tie: exactly one request ends up
    # with the lock and the other renders the lockout screen.
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
    EditingSession.purge_stale_for(record_type: record.class.name, record_id: record.id)
    EditingSession.create_or_find_by!(
      user: current_user,
      record_type: record.class.name,
      record_id: record.id
    )
  end

  def release_edit_session(record)
    EditingSession.for_record(record).where(user: current_user).destroy_all
  end
end
