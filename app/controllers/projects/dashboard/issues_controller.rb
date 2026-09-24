class Projects::Dashboard::IssuesController < AuthenticatedController
  include ProjectScoped
  include Projects::IssuesSummaryGrouping

  def index
    @issues = current_project.issues.includes(:tags).sort
    @tags = current_project.tags

    build_grouping(params[:grouping])
  end
end
