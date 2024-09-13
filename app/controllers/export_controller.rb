class ExportController < AuthenticatedController
  include ProjectScoped

  NON_DRAFT_STATES = ['published', 'ready_for_review'].freeze

  def index
    @default_button_state = non_draft_records? ? 'published' : 'all'
  end

  private

  def non_draft_records?
    issue_states = current_project.issues.pluck(:state).uniq
    (issue_states & NON_DRAFT_STATES).any? || non_draft_records_pro
  end

  def non_draft_records_pro
    false
  end

  # In case something goes wrong with the export, fail graciously instead of
  # presenting the obscure Error 500 default page of Rails.
  def rescue_action(exception)
    flash[:error] = exception.message
    redirect_to project_upload_manager_path(current_project)
  end
end
