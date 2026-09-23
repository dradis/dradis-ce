class Cards::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  before_action :set_card

  private

  def editing_session_record
    @card
  end

  def set_card
    @board = current_project.boards.find(params[:board_id])
    @list = @board.lists.find(params[:list_id])
    @card = @list.cards.find(params[:card_id])
  end
end
