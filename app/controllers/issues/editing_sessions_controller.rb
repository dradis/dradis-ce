class Issues::EditingSessionsController < AuthenticatedController
  include ProjectScoped

  before_action :set_issue

  def destroy
    @issue.release_edit_session(current_user)
    head :no_content
  end

  private

  def set_issue
    @issue = current_project.issues.find(params[:issue_id])
  end
end
