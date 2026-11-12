class Lists::PositionController < AuthenticatedController
  include EventPublisher
  include ProjectScoped

  before_action :set_current_board
  before_action :set_list

  def update
    @list.move_to(**move_params.to_h.symbolize_keys)
    publish_event('list.updated', @list.to_event_payload)

    render json: @list
  rescue ActiveRecord::RecordInvalid
    redirect_to project_board_path(current_project, @board), alert: 'Something fishy is going on...'
  end

  private

  def move_params
    params.permit(:next_id, :prev_id)
  end

  def set_current_board
    @board = current_project.boards.find(params[:board_id])
  end

  def set_list
    @list = @board.lists.find(params[:list_id])
  end
end
