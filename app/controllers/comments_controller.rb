class CommentsController < AuthenticatedController
  load_and_authorize_resource

  include ActivityTracking
  include Mentioned
  include Notified

  layout false

  def index
    @comments = commentable.comments.includes(:user)
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment)
      broadcast_notifications(
        action: :create,
        notifiable: @comment,
        user: current_user
      )
    end
  end

  def update
    if @comment.update(comment_params)
      track_updated(@comment)
    end
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def commentable
    @commentable ||= begin
      if @comment
        @comment.commentable
      else
        commentable_class.find(comment_params[:commentable_id])
      end
    end
  end

  def commentable_class
    if Commentable.allowed_types.include?(comment_params[:commentable_type])
      comment_params[:commentable_type].constantize
    else
      raise 'Invalid commentable'
    end
  end

  # Overwrite method from concerns/mentioned.rb
  def project
    @project ||= begin
      if commentable.respond_to?(:project)
        commentable.project
      else
        nil
      end
    end
  end
end
