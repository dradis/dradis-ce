module Dradis::CE::API
  module V3
    class BoardsController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include EventPublisher

      def index
        @boards = current_project.boards.includes(lists: { cards: :assignees }).order('updated_at desc')
        @boards = @boards.page(params[:page].to_i) if params[:page]
      end

      def show
        @board = current_project.boards.includes(lists: { cards: :assignees }).find(params[:id])
      end

      def create
        @board = current_project.boards.new(board_params)
        # we are mimicking the hidden_field used in the UI to set the node_id in CE
        @board.node_id = current_project.methodology_library.id if !params[:node_id]

        if @board.save
          publish_event('board.created', @board.to_event_payload)
          render status: 201, location: dradis_api.board_url(@board)
        else
          render_validation_errors(@board)
        end
      end

      def update
        @board = current_project.boards.find(params[:id])
        if @board.update(board_params)
          publish_event('board.updated', @board.to_event_payload)
          render board: @board
        else
          render_validation_errors(@board)
        end
      end

      def destroy
        board = current_project.boards.find(params[:id])
        board.destroy
        publish_event('board.destroyed', board.to_event_payload)
        render_successful_destroy_message
      end

      protected

      def board_params
        params.require(:board).permit(:name, :node_id)
      end
    end
  end
end
