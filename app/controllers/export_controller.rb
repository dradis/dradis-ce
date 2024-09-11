class ExportController < AuthenticatedController
  include ProjectScoped

  def index
    @default_button_state = non_draft_records? ? 'published' : 'all'
  end

  private

  def non_draft_records?
    issue_states = current_project.issues.pluck(:state).uniq
    non_draft_states = ['published', 'ready_for_review']

    (issue_states & non_draft_states).any?
  end

  # In case something goes wrong with the export, fail graciously instead of
  # presenting the obscure Error 500 default page of Rails.
  def rescue_action(exception)
    flash[:error] = exception.message
    redirect_to project_upload_manager_path(current_project)
  end
end
