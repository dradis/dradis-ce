class Issues::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  before_action :set_issue

  private

  def editing_session_record
    @issue
  end

  def set_issue
    @issue = current_project.issues.find(params[:issue_id])
  end
end
