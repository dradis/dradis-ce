class Cards::PositionController < AuthenticatedController
  include EventPublisher
  include ProjectScoped

  before_action :set_current_board_and_list
  before_action :set_card

  def update
    moved = @card.move_to(**move_params.to_h.symbolize_keys)
    publish_event('card.updated', @card.to_event_payload) if moved
    @card.reload

    respond_to do |format|
      format.html do
        message = moved ? { notice: 'Task moved.' } : { alert: 'Task is already in that list.' }
        redirect_to project_board_list_card_path(current_project, @board, @card.list, @card), **message
      end

      format.json do
        render json: {
          is_card: true,
          id: @card.id,
          link: polymorphic_path([current_project, @board, @card.list, @card]),
          moveLink: project_board_list_card_position_path(current_project, @board, @card.list, @card)
        }
      end
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to project_board_path(current_project, @board), alert: 'Something fishy is going on...'
  end

  private

  def move_params
    params.permit(:new_list_id, :next_id, :prev_id)
  end

  def set_card
    @card = @board.cards.find(params[:card_id])
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list = @board.lists.includes(:cards).find(params[:list_id])
  end
end
