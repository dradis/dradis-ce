class Projects::Dashboard::IssuesController < AuthenticatedController
  include ProjectScoped
  include Projects::IssuesSummaryGrouping

  def index
    @issues = current_project.issues.includes(:tags).sort
    @tags = current_project.tags
    @list_fields = list_fields

    build_grouping(params[:grouping])
  end
end
