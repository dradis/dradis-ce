class TasksController < AuthenticatedController
  include ProjectScoped
  layout 'tylium'
  def index
    @tasks = current_user.cards
  end
end
