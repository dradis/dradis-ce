class TasksController < AuthenticatedController
  include ProjectScoped
  include Tasks

  def index
    @default_columns = ['Title', 'Methodology', 'List', 'Due Date', 'Assigned']
    @tasks = assigned_tasks
  end
end
