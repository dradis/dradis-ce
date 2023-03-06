class QA::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = Issue.ready_for_review
    @all_columns = ['Title']
  end
end
