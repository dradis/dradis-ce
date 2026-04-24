module Tasks
  extend ActiveSupport::Concern

  def assigned_tasks
    Card
      .joins(list: :board)
      .where(boards: { id: current_project.boards })
      .joins(:assignees)
      .where(users: { id: current_user.id })
      .includes(:assignees, list: :board)
      .sort_by { |card| [card.due_date.nil? ? 1 : 0, card.due_date] }
  end
end
