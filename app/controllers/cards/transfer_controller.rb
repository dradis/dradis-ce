class Cards::TransferController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped

  before_action :set_current_board_and_list
  before_action :set_card

  def create
    target_list = @board.lists.find(params[:new_list_id])

    if target_list.id == @card.list_id
      redirect_to [current_project, @board, @list, @card], alert: 'Task is already in that list.'
      return
    end

    Card.transaction do
      if (next_card = @card.next_card)
        next_card.update_attribute(:previous_id, @card.previous_id)
      end

      @card.list_id = target_list.id
      @card.previous_id = target_list.last_card&.id
      @card.save!
    end

    track_updated(@card)
    redirect_to [current_project, @board, target_list, @card], notice: 'Task moved.'
  end

  private

  def set_card
    @card = @board.cards.find(params[:card_id])
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list = @board.lists.includes(:cards).find(params[:list_id])
  end
end
