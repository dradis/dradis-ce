module Dradis::CE::API
  module V3
    class ListsController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include EventPublisher

      before_action :set_board

      def index
        @lists = @board.lists.includes(:cards, cards: :assignees).order('updated_at desc')
        @lists = @lists.page(params[:page].to_i) if params[:page]
      end

      def show
        @list = @board.lists.includes(:cards, cards: :assignees).find(params[:id])
      end

      def create
        @list = @board.lists.build(list_params)
        @list.previous_id = @board.last_list.try(:id)

        if @list.save
          publish_event('list.created', @list.to_event_payload)
          render status: 201, location: board_list_path(@board, @list)
        else
          render_validation_errors(@list)
        end
      end

      def update
        @list = @board.lists.find(params[:id])
        if @list.update(list_params)
          publish_event('list.updated', @list.to_event_payload)
          render list: @list
        else
          render_validation_errors(@list)
        end
      end

      def destroy
        @list = @board.lists.find(params[:id])
        @list.destroy
        publish_event('list.destroyed', @list.to_event_payload)
        render_successful_destroy_message
      end

      private

      def set_board
        @board = current_project.boards.includes(:lists).find(params[:board_id])
      end

      def list_params
        params.require(:list).permit(:name)
      end
    end
  end
end
