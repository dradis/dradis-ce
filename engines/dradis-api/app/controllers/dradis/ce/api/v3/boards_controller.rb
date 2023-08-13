module Dradis::CE::API
  module V3
    class BoardsController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      def index
        @boards = current_project.boards.includes(:lists, lists: [:cards]).order('updated_at desc')
        @boards = @boards.page(params[:page].to_i) if params[:page]
      end

      def show
        @board = current_project.boards.includes(:lists, lists: [:cards]).find(params[:id])
      end

      def create
        @board = current_project.boards.new(board_params)

        if @board.save
          track_created(@board)
          render status: 201, location: dradis_api.board_url(@board)
        else
          render_validation_errors(@board)
        end
      end

      def update
        @board = current_project.boards.find(params[:id])
        if @board.update(board_params)
          track_updated(@board)
          render board: @board
        else
          render_validation_errors(@board)
        end
      end

      def destroy
        board = current_project.boards.find(params[:id])
        board.destroy
        track_destroyed(board)
        render_successful_destroy_message
      end

      protected

      def board_params
        params.require(:board).permit(:name, :node_id)
      end
    end
  end
end
