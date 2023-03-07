class QA::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = Issue.ready_for_review
    @all_columns = ['Title']
  end

  def multiple_update
    @issues = Issue.where(id: params[:ids])

    @issues.update_all(state: params[:state].parameterize(separator: '_'))

    head :ok
  end
end
