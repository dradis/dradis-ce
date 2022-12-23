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
    if @prev_item.present?
      next_item_of_prev_item = @prev_item.send("next_#{controller_name.classify.downcase}")
      if next_item_of_prev_item
        @next_item == next_item_of_prev_item
      else
        @next_item.nil?
      end
    else
      if @parent.items.empty?
        @next_item.nil?
      else
        @next_item == @parent.first_item
      end
    end
  end
end
