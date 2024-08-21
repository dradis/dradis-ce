class TasksController < AuthenticatedController
  include ProjectScoped

  skip_before_action :set_project, if: -> { params[:project_id].blank? }
  skip_before_action :set_nodes, if: -> { params[:project_id].blank? }

  layout :set_layout
  def index
    @default_columns = ['Title', 'Methodology', 'Due Date', 'Assigned']

    if params[:project_id].present?
      cards = current_project.methodology_library.boards.map(&:cards)[0]
      @local_storage_key = "project.ce.project_#{current_project.id}.tasks_datatable"
    else
      cards = current_user.cards
      @default_columns.insert(1, 'Project')
      @local_storage_key = 'project.pro.tasks_datatable'
    end

    @tasks = if cards
      cards.filter_map { |card| card if card.assignees.include? current_user }
    else
      []
    end
  end

  protected

  # ProjectScoped always calls current_project. We are overwriting it here to
  # prevent errors in Pro when viewing tasks outside of projects.
  def current_project
    return if params[:project_id].blank?

    super
  end

  def set_layout
    params[:project_id].present? ? 'tylium' : 'mintcreek'
  end
end
