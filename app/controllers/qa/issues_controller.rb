class QA::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = @default_columns = ['Title']
  end

  def multiple_update
    @issues = current_project.issues.ready_for_review.where(id: params[:ids])

    @issues.update_all(state: params[:state].parameterize(separator: '_'))

    head :ok
  end
end
