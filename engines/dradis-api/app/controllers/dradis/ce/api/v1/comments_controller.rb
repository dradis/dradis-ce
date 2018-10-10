module Dradis::CE::API
  module V1
    class CommentsController < Dradis::CE::API::V1::ProjectScopedController
      before_action :set_comment, only: [:show, :update, :destroy]
      before_action :set_commentable, only: [:index, :create]

      def index
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
        regex = /(?<=\/api\/)([a-z]+)(?=\/)/
        commentable_type = request.original_fullpath[regex].singularize
        commentable_class = commentable_type.capitalize.constantize

        @commentable = commentable_class.find(params["#{commentable_type}_id"])
      end

      def set_comment
        @comment = Comment.find(params[:id])
      end
    end
  end
end
