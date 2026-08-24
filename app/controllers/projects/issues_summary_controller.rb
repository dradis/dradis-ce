class Projects::IssuesSummaryController < AuthenticatedController
  include IssuesDimensionGrouping
  include ProjectScoped

  def show
    @issues = current_project.issues.includes(:tags).sort
    @tags = current_project.tags

    build_all_tags_grouping
  end
end
