class QA::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = ['Title']
  end
end
