class Lists::PositionController < AuthenticatedController
  include ActivityTracking
  include LinkedListMoveValidator
  include ProjectScoped

  before_action :set_current_board
  before_action :set_list
  before_action :set_prev_item_and_next_item
  before_action :validate_move_params

  def create
    Board.move(@list, prev_item: @prev_item, next_item: @next_item)

    track_updated(@list)

    render json: @list
  end

  private

  def move_params
    params.permit(:list_id, :project_id, :board_id, :next_id, :prev_id)
  end

  def moveable_item_name
    'list'
  end

  def moveable_items
    @board.lists
  end

  def moveable_parent
    @board
  end

  def set_current_board
    @board = current_project.boards.find(params[:board_id])
  end

  def set_list
    @list = @board.lists.find(params[:list_id])
  end
end
