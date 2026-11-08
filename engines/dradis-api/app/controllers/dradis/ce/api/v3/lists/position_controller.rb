module Dradis::CE::API
  module V3
    class Lists::PositionController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include EventPublisher

      before_action :set_list

      def update
        @board.move(@list, **move_params.to_h.symbolize_keys)
        publish_event('list.updated', @list.to_event_payload)
      rescue ActiveRecord::RecordInvalid
        render_validation_errors(@list)
      end

      private

      def move_params
        params.permit(:next_id, :prev_id)
      end

      def set_list
        @board = current_project.boards.find(params[:board_id])
        @list = @board.lists.find(params[:list_id])
      end
    end
  end
end
