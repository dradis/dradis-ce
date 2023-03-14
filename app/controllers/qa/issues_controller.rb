class QA::IssuesController < AuthenticatedController
  include LiquidEnabledResource
  include ProjectScoped

  before_action :set_issues
  before_action :set_issue, only: [:show, :update]
  before_action :validate_state, only: :update

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = @default_columns = ['Title']
  end

  def show; end

  def update
    if @issue.update(issue_params)
      redirect_to project_qa_issues_path(current_project), notice: 'State updated successfully.'
    else
      render :show, alert: @issue.errors.full_messages.join('; ')
    end
  end

  private

  def issue_params
    params.permit(:state)
  end

  def set_issue
    @issue = current_project.issues.find(params[:id])
  end

  def set_issues
    @issues = current_project.issues.ready_for_review
  end

  def validate_state
    redirect_to project_qa_issue_path(current_project, @issue), alert: 'Something fishy is going on...' unless Issue.states.keys.include?(params[:state])
  end
end
