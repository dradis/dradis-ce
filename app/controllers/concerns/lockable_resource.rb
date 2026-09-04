module LockableResource
  extend ActiveSupport::Concern

  protected

  def check_edit_lock
    editing_session = EditingSession.for_record(lockable_resource)

    if editing_session&.active? && editing_session.user != current_user && params[:force] != 'true'
      @locked_by = editing_session.user
      # Make the record accessible in the view
      @locked_record = lockable_resource
      render 'shared/edit_locked'
      return
    end

    lockable_resource.acquire_edit_session(current_user)
  end

  # Controllers that lock a record must return it here.
  def lockable_resource
    raise NotImplementedError, "#{self.class.name} must implement #lockable_resource"
  end
end
