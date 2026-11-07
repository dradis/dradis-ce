class ListsController < AuthenticatedController
  include EventPublisher
  include ProjectScoped

  before_action :set_current_board
  before_action :set_list, only: [:edit, :update, :destroy]

  def new
    @list = @board.lists.new
  end

  def create
    @list = @board.lists.new(list_params)
    @list.previous_id = @board.last_list.try(:id)

    if @list.save
      publish_event('list.created', @list.to_event_payload)
      redirect_to [current_project, @board], notice: 'List added.'
    else
      redirect_to [current_project, @board], alert: @list.errors.full_messages.join('; ')
    end
  end

  def edit; end

  def update
    if @list.update(list_params)
      publish_event('list.updated', @list.to_event_payload)
      redirect_to [current_project, @board], notice: 'List renamed.'
    else
      redirect_to [current_project, @board], alert: @list.errors.full_messages.join('; ')
    end
  end

  def destroy
    if @list.destroy
      publish_event('list.destroyed', @list.to_event_payload)
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
