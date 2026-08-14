class Issues::EditingSessionsController < AuthenticatedController
  include ProjectScoped

  def destroy
    issue.release_edit_session(current_user)
    head :no_content
  end

  private

  def issue
    @issue ||= current_project.issues.find(params[:issue_id])
  end
end
