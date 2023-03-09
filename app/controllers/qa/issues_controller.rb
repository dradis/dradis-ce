class QA::IssuesController < AuthenticatedController
  include LiquidEnabledResource
  include ProjectScoped

  before_action :set_issues
  before_action :set_issue, only: [:show, :update_state]

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = @default_columns = ['Title']
  end

  def show; end

  def update_state
    @issue.update(state: params[:state])
    redirect_to project_qa_issues_path(current_project), notice: 'State updated successfully.'
  end

  private

  def set_issue
    @issue = current_project.issues.find(params[:id])
  end

  def set_issues
    @issues = current_project.issues.ready_for_review
  end
end
