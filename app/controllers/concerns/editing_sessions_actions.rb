module EditingSessionsActions
  extend ActiveSupport::Concern

  def destroy
    editing_session_record.release_edit_session(current_user)
    head :no_content
  end

  private

  # Controllers including this must implement #editing_session_record to
  # return the locked resource whose session should be released.
  def editing_session_record
    raise NotImplementedError, "#{self.class.name} must implement #editing_session_record"
  end
end
