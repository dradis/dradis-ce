module Dradis::CE::API
  module V1
    class CommentsController < Dradis::CE::API::V1::ProjectScopedController
      before_action :set_comment, only: [:show, :update, :destroy]
      before_action :set_commentable, only: [:index, :create]

      def index
        @comments = @commentable.comments
      end

      def show; end

      def create
      end

      def update
      end

      def destroy
      end

      private

      def set_commentable
        @commentable =
          if params[:issue_id]
           Issue.find(params[:issue_id])
          elsif params[:note_id]
            Note.find(params[:note_id])
          elsif params[:evidence_id]
            Evidence.find(params[:evidence_id])
          else
            raise 'Polymorphic model missing!'
          end
      end

      def set_comment
        @comment = Comment.find(params[:id])
      end
    end
  end
end
