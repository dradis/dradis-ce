class Cards::PositionController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped
  include ValidateMove

  before_action :set_current_board_and_list
  before_action :set_card
  before_action :set_prev_item_and_next_item
  before_action :validate_move_params

  def create
    List.move(@card, prev_item: @prev_item, next_item: @next_item)

    if new_list
      @card.list = new_list
      @card.save
    end

    track_updated(@card)

    render json: {
      is_card: true,
      id: @card.id,
      link: polymorphic_path([current_project, @board, @card.reload.list, @card]),
      moveLink: project_board_list_card_position_path(current_project, @board, @card.reload.list, @card)
    }
  end

  private

  def move_params
    params.permit(:card_id, :project_id, :board_id, :list_id, :next_id, :prev_id, :new_list_id)
  end

  def moveable_items
    @board.cards
  end

  def moveable_item_name
    'card'
  end

  def moveable_parent
    new_list || @list
  end

  def new_list
    @board.lists.find(move_params[:new_list_id]) if move_params[:new_list_id]
  end

  def set_card
    @card = @board.cards.find(params[:card_id])
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list = @board.lists.includes(:cards).find(params[:list_id])
  end
end
