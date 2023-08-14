module Dradis::CE::API
  module V3
    class CardsController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_board
      before_action :set_list

      def index
        @cards = @list.cards.includes(:assignees).order('updated_at desc')
        @cards = @cards.page(params[:page].to_i) if params[:page]
      end

      def show
        @card = @list.cards.includes(:assignees).find(params[:id])
      end

      def create
        @card = @list.cards.build(card_params)
        # Set the new card as the last card of the list
        @card.previous_id = @list.last_card.try(:id)

        if @card.save
          track_created(@card)
          render status: 201, location: board_list_card_path(@board, @list, @card)
        else
          render_validation_errors(@card)
        end
      end

      def update
        @card = @list.cards.find(params[:id])
        if @card.update(card_params)
          track_updated(@card)
          render list: @card
        else
          render_validation_errors(@card)
        end
      end

      def destroy
        @card = @list.cards.find(params[:id])
        @card.destroy
        track_destroyed(@card)
        render_successful_destroy_message
      end

      private

      def set_board
        @board = current_project.boards.includes(:lists).find(params[:board_id])
      end

      def set_list
        @list = @board.lists.includes(:cards, cards: :assignees).find(params[:list_id])
      end

      def card_params
        params.require(:card).permit(:name, :description, :due_date, assignee_ids: [])
      end

    end
  end
end
