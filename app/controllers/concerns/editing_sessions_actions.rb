module EditingSessionsActions
  extend ActiveSupport::Concern

  def destroy
    lockable_resource.release_edit_session(current_user)
    head :no_content
  end

  private

  # Controllers that release a lock must return the locked record here.
  def lockable_resource
    raise NotImplementedError, "#{self.class.name} must implement #lockable_resource"
  end
end
