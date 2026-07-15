class Cards::PositionController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped
  include ValidateMove

  before_action :set_current_board_and_list
  before_action :set_card
  before_action :require_list_change, if: :append_to_list?
  before_action :set_prev_item_and_next_item
  before_action :validate_move_params

  def create
    Card.transaction do
      List.move(@card, prev_item: @prev_item, next_item: @next_item)

      if new_list
        @card.list = new_list
        @card.save!
      end
    end

    track_updated(@card)
    @card.reload

    respond_to do |format|
      format.html do
        redirect_to project_board_list_card_path(current_project, @board, @card.list, @card),
          notice: 'Task moved.'
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
  end

  private

  # A request with a new_list_id but no explicit position appends the card to
  # the end of the target list (e.g. the 'move to list' dropdown).
  def append_to_list?
    move_params[:new_list_id].present? &&
      move_params[:prev_id].blank? &&
      move_params[:next_id].blank?
  end

  def move_params
    params.permit(:card_id, :project_id, :board_id, :list_id, :next_id, :prev_id, :new_list_id)
  end

  def moveable_item_name
    'card'
  end

  def moveable_items
    @board.cards
  end

  def moveable_parent
    new_list || @list
  end

  def new_list
    return if move_params[:new_list_id].blank?

    @new_list ||= @board.lists.find(move_params[:new_list_id])
  end

  def require_list_change
    return if new_list.id != @card.list_id

    redirect_to project_board_list_card_path(current_project, @board, @list, @card),
      alert: 'Task is already in that list.'
  end

  def set_card
    @card = @board.cards.find(params[:card_id])
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list = @board.lists.includes(:cards).find(params[:list_id])
  end

  def set_prev_item_and_next_item
    if append_to_list?
      @prev_item = new_list.last_card
      @next_item = nil
    else
      super
    end
  end
end
