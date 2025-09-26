module Tasks
  extend ActiveSupport::Concern

  def assigned_tasks
    current_project.boards.includes(lists: :cards)
      .flat_map { |board| board.lists.flat_map(&:cards) }
      .select { |card| card.assignees.include?(current_user) }
      .sort_by { |card| [card.due_date.nil? ? 1 : 0, card.due_date] }
  end
end
