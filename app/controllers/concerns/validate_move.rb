module ValidateMove
  extend ActiveSupport::Concern
  PERMITTED_MOVE_PARAMS = %w(prev_id next_id new_list_id)

  included do
    before_action :validate_move_params, only: :move
  end

  protected

  def validate_move_params
    head :unprocessable_entity unless valid_move_params?

    if move_params.has_key?(:prev_id)
      head :unprocessable_entity unless valid_prev_id?
    end
  end

  def valid_move_params?
    (PERMITTED_MOVE_PARAMS & move_params.keys).any?
  end

  def valid_prev_id?
    controller_name.classify.constantize.exists?(move_params[:prev_id])
  end
end
