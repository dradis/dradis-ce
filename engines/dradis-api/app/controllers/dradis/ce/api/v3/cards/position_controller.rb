module Dradis::CE::API
  module V3
    class Cards::PositionController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include EventPublisher

      before_action :set_card

      def update
        moved = @card.move_to(**move_params.to_h.symbolize_keys)
        publish_event('card.updated', @card.to_event_payload) if moved
        @card.reload
      rescue ActiveRecord::RecordInvalid
        render_validation_errors(@card)
      end

      private

      def move_params
        params.permit(:new_list_id, :next_id, :prev_id)
      end

      def set_card
        @board = current_project.boards.find(params[:board_id])
        @list = @board.lists.find(params[:list_id])
        @card = @list.cards.find(params[:card_id])
      end
    end
  end
end
