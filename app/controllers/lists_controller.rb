class ListsController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped

  before_action :set_current_board
  before_action :set_list, only: [:show, :edit, :update, :destroy, :move]

  def new
    @list = @board.lists.new
  end

  def create
    @list = @board.lists.new(list_params)
    @list.previous_id = @board.last_list.try(:id)

    if @list.save
      track_created(@list)
      redirect_to [current_project, @board], notice: 'List added.'
    else
      redirect_to [current_project, @board], alert: @list.errors.full_messages.join('; ')
    end
  end

  def edit; end

  def update
    if @list.update(list_params)
      track_updated(@list)
      redirect_to [current_project, @board], notice: 'List renamed.'
    else
      redirect_to [current_project, @board], alert: @list.errors.full_messages.join('; ')
    end
  end

  def move
    Board.move(
      @list,
      prev_item: @board.lists.find_by(id: params[:prev_id]),
      next_item: @board.lists.find_by(id: params[:next_id])
    )

    track_updated(@list)

    render json: @list
  end

  def destroy
    if @list.destroy
      track_destroyed(@list)
      redirect_to [current_project, @board], notice: 'List deleted.'
    else
      redirect_to [current_project, @board], notice: "Error deleting list: #{@list.errors.full_messages.join('; ')}"
    end
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end

  def set_current_board
    @board = current_project.boards.find(params[:board_id])
  end

  def set_list
    @list = @board.lists.find(params[:id])
  end
end
