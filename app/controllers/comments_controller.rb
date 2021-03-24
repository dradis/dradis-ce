class CommentsController < AuthenticatedController
  include ActivityTracking
  include Notified

  layout false

  load_and_authorize_resource

  before_action :find_mentionable_users, only: [:index, :create, :update]

  def index
    @comments = commentable.comments.includes(:user)
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment, project: commentable.project)
      broadcast_notifications(
        action: :create,
        notifiable: @comment,
        user: current_user
      )
    end
  end

  def update
    if @comment.update(comment_params)
      track_updated(@comment, project: commentable.project)
    end
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment, project: commentable.project)
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
    if Comment::COMMENTABLE_TYPES.include?(comment_params[:commentable_type])
      comment_params[:commentable_type].constantize
    else
      raise 'Invalid commentable'
    end
  end

  def find_mentionable_users
    @mentionable_users ||= commentable.project.testers_for_mentions
  end
end
