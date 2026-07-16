class ProjectsController < AuthenticatedController
  include IssuesDimensionGrouping
  include NotificationsReader

  before_action :set_project

  helper :hera
  helper_method :current_project

  def index
    redirect_to project_path(current_project)
  end

  def show
    @activities = Activity.latest
    @authors = [current_user]
    @boards = current_project.methodology_library.boards
    @issues = current_project.issues.includes(:tags).sort
    @methodologies = current_project.methodology_library.notes.map { |n| Methodology.new(filename: n.id, content: n.text) }
    @nodes = current_project.nodes.in_tree
    @tags = current_project.tags

    build_all_tags_grouping

    respond_to do |format|
      format.html { render layout: 'hera/project' if !request.xhr? }
      format.json { render json: @boards }
    end
  end

  private
  def set_project
    current_project
  end

  def current_project
    @current_project ||= Project.new
  end
end
