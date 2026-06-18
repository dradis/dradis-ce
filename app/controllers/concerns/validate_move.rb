module ValidateMove
  extend ActiveSupport::Concern

  protected

  def set_prev_item_and_next_item
    @prev_item = moveable_items.find_by(id: move_params[:prev_id])
    @next_item = moveable_items.find_by(id: move_params[:next_id])
  end

  def validate_move_params
    unless valid_move_params?
      redirect_to project_board_path(current_project, @board), alert: 'Something fishy is going on...'
    end
  end

  private

  def valid_move_params?
    if @prev_item.present?
      next_item_of_prev_item = @prev_item.send("next_#{moveable_item_name}")
      if next_item_of_prev_item
        @next_item == next_item_of_prev_item
      else
        @next_item.nil?
      end
    else
      if moveable_parent.items.empty?
        @next_item.nil?
      else
        @next_item == moveable_parent.first_item
      end
    end
  end
end
