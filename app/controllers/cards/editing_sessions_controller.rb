class Cards::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  private

  def lockable_resource
    board = current_project.boards.find(params[:board_id])
    list = board.lists.find(params[:list_id])
    list.cards.find(params[:card_id])
  end
end
