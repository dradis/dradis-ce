class TasksController < AuthenticatedController
  include ProjectScoped

  before_action :set_tasks, only: :index

  skip_before_action :set_project, if: -> { params[:project_id].blank? }
  skip_before_action :set_nodes, if: -> { params[:project_id].blank? }

  def index
    @default_columns = ['Title', 'Methodology', 'Due Date', 'Assigned']

    if params[:project_id].present?
      @local_storage_key = "project.ce.project_#{current_project.id}.tasks_datatable"
    else
      @default_columns.insert(1, 'Project')
      @local_storage_key = 'pro.tasks_datatable'
    end
  end

  protected

  # ProjectScoped always calls current_project. We are overwriting it here to
  # prevent errors in Pro when viewing tasks outside of projects.
  def current_project
    return if params[:project_id].blank?

    super
  end

  def set_tasks
    @tasks ||= begin
      cards = current_user.cards

      if params[:project_id].present?
        cards.select { |card| card.project.id == current_project.id }
      else
        cards
      end
    end
  end
end
