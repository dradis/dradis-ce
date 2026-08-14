class Issues::EditingSessionsController < AuthenticatedController
  include LockableResource
  include ProjectScoped

  def destroy
    release_edit_session(issue)
    head :no_content
  end

  private

  def issue
    @issue ||= current_project.issues.find(params[:issue_id])
  end
end
