module Dradis::CE::API
  module V3
    class ListsController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_board

      def index
        @lists = @board.lists.order('updated_at desc')
        @lists = @lists.page(params[:page].to_i) if params[:page]
      end

      def show
        @list = @board.lists.find(params[:id])
      end

      def create
        @list = @board.lists.build(list_params)
        if @list.save
          track_created(@list)
          render status: 201, location: board_list_path(@board, @list)
        else
          render_validation_errors(@list)
        end
      end

      def update
        @list = @node.lists.find(params[:id])
        if @list.update(list_params)
          track_updated(@list)
          render list: @list
        else
          render_validation_errors(@list)
        end
      end

      def destroy
        @list = @board.lists.find(params[:id])
        @list.destroy
        track_destroyed(@list)
        render_successful_destroy_message
      end

      private

      def set_board
        @board = current_project.boards.find(params[:board_id])
      end

      def list_params
        params.require(:list).permit(:name)
      end

    end
  end
end
