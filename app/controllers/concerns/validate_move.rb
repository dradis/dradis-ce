module ValidateMove
  extend ActiveSupport::Concern
  included do
    before_action :set_prev_item_and_next_item, only: :move
    before_action :validate_move_params, only: :move
  end

  protected

  def set_prev_item_and_next_item
    @prev_item = @board.send(controller_name).find_by(id: move_params[:prev_id])
    @next_item = @board.send(controller_name).find_by(id: move_params[:next_id])
  end

  def validate_move_params
    unless valid_move_params?
      redirect_to project_board_path(current_project, @board), alert: 'Something fishy is going on...'
    end
  end

  def parent
    if controller_name == 'cards'
      new_list || @list
    elsif controller_name == 'lists'
      @board
    end
  end

  def valid_move_params?
    if @prev_item.present?
      next_item_of_prev_item = @prev_item.send("next_#{controller_name.classify.downcase}")
      if next_item_of_prev_item
        @next_item == next_item_of_prev_item
      else
        @next_item.nil?
      end
    else
      if parent.items.empty?
        @next_item.nil?
      else
        @next_item == parent.first_item
      end
    end
  end
end
