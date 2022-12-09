module ValidateMove
  extend ActiveSupport::Concern

  included do
    before_action :validate_previous_id, only: :move
  end

  protected

  def validate_previous_id
    return true if params[:next_id].present? && params[:prev_id].blank?

    head :unprocessable_entity unless controller_name.classify.constantize.exists? params[:prev_id]
  end
end
