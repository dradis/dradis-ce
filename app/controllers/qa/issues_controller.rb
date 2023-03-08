class QA::IssuesController < AuthenticatedController
  include LiquidEnabledResource
  include ProjectScoped

  before_action :set_issues

  def index
    @all_columns = ['Title']
  end

  def show
    @issue = current_project.issues.find(params[:id])
  end

  private

  def set_issues
    @issues = current_project.issues.ready_for_review
  end
end
