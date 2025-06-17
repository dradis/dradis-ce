class TasksController < AuthenticatedController
  include ProjectScoped
  include TasksHelper

  def index
    @default_columns = ['Title', 'Methodology', 'List', 'Due Date', 'Assigned']
    @tasks = current_project.boards.includes(lists: :cards)
              .flat_map { |board| board.lists.flat_map(&:cards) }
              .select { |card| card.assignees.include?(current_user) }
              .sort_by { |card| [card.due_date.nil? ? 1 : 0, card.due_date] }
  end
end
