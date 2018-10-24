module Dradis::CE::API
  module V1
    class CommentsController < Dradis::CE::API::V1::ProjectScopedController
      before_action :set_comment, only: [:show, :update, :destroy]
      before_action :set_commentable

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
        commentable_klasses = %w[issue note evidence]
        if klass = commentable_klasses.detect { |ck| params[:"#{ck}_id"].present? }
          @commentable =
            current_project.send(klass.pluralize).find(params[:"#{klass}_id"])
        end
      end

      def set_comment
        @comment = @commentable.comments.find(params[:id])
      end
    end
  end
end
