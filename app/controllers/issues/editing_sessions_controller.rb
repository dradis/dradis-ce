class Issues::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  private

  def lockable_resource
    current_project.issues.find(params[:issue_id])
  end
end
