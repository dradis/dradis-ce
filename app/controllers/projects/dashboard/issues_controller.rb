class Projects::Dashboard::IssuesController < AuthenticatedController
  include Projects::IssuesSummaryGrouping
  include ProjectScoped

  def index
    @issues = current_project.issues.includes(:tags).sort
    @tags = current_project.tags

    build_tags_grouping
  end
end
