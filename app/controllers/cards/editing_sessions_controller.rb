class Cards::EditingSessionsController < AuthenticatedController
  include ProjectScoped

  before_action :set_card

  def destroy
    @card.release_edit_session(current_user)
    head :no_content
  end

  private

  def set_card
    @board = current_project.boards.find(params[:board_id])
    @list = @board.lists.find(params[:list_id])
    @card = @list.cards.find(params[:card_id])
  end
end
