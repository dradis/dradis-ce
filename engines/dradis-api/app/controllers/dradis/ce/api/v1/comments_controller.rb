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
        @comment = @commentable.comments.build(comment_params)
        @comment.user = current_user
        if @comment.save
          track_created(@comment)
          render status: 201, location: @commentable
        else
          render_validation_errors(@comment)
        end
      end

      def update
        if @comment.update_attributes(comment_params)
          track_updated(@comment)
        else
          render_validation_errors(@comment)
        end
      end

      def destroy
        @comment.destroy
        track_destroyed(@comment)
        render_successful_destroy_message
      end

      private

      def comment_params
        params.require(:comment).permit(:content)
      end

      def set_commentable
        begin
          id_param = params.keys.select { |key| key =~ /_id$/ }.first
          id_value = params[id_param]

          klass = id_param.chomp('_id').capitalize.constantize
          @commentable = klass.find(id_value)
        rescue
          raise 'Could not find commentable resource'
        end
      end

      def set_comment
        @comment = Comment.find(params[:id])
      end
    end
  end
end
