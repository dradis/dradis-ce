class QA::IssuesController < AuthenticatedController
  include ProjectScoped

  before_action :validate_state, only: :update

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = @default_columns = ['Title']
  end

  def update
    @issues = current_project.issues.ready_for_review.where(id: params[:ids])

    @issues.update_all(state: @state, updated_at: Time.now)

    head :ok
  end

  private

  def validate_state
    if Issue.states.keys.include?(params[:state])
      @state = params[:state]
    else
      redirect_to project_qa_issues_path(current_project), alert: 'Something fishy is going on...'
    end
  end
end
