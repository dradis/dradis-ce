module ValidateMove
  extend ActiveSupport::Concern
  included do
    before_action :validate_move_params, only: :move
  end

  protected

  def validate_move_params
    head :unprocessable_entity unless valid_move_params?
  end

  def valid_move_params?
    if move_params[:prev_id] == nil
      if @parent.items.empty?
        move_params[:next_id] == nil
      else
        if @parent.first_item
          @next_item == @parent.first_item
        else
          move_params[:next_id] == nil
        end
      end
    else
      if @parent.items.exists? move_params[:prev_id]
        next_item_of_new_prev_item = @prev_item.send("next_#{controller_name.classify.downcase}")
        if next_item_of_new_prev_item
          @next_item == next_item_of_new_prev_item
        else
          move_params[:next_id] == nil
        end
      else
        false
      end
    end
  end
end
