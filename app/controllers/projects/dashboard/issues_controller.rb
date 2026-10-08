class Projects::Dashboard::IssuesController < AuthenticatedController
  include ProjectScoped

  before_action :set_grouping

  def index
    @issues = current_project.issues.includes(:tags).sort
    @groups = @grouping.groups(@issues)
  end

  private

  def set_grouping
    @groupings = Projects::Dashboard::Issues::Grouping.available(current_project)
    @grouping = Projects::Dashboard::Issues::Grouping.find(current_project, params[:grouping])
  end
end
