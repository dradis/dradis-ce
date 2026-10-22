class Projects::Dashboard::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = current_project.issues.includes(:tags).sort
    @groupings = Projects::Dashboard::Issues::Grouping.available(current_project)
    @grouping = @groupings.find { |grouping| grouping.key == params[:grouping] } || @groupings.first
    @groups = @grouping.groups(@issues)
  end
end
