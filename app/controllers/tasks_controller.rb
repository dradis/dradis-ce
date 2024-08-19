class TasksController < AuthenticatedController
  include ProjectScoped
  layout 'tylium'
  def index
    project_cards = current_project.methodology_library.boards.map(&:cards)[0]

    @tasks = if project_cards
      project_cards.filter_map { |card| card if card.assignees.include? current_user }
    else
      []
    end
  end
end
