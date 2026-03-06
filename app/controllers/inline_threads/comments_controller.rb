class InlineThreads::CommentsController < AuthenticatedController
  include EventPublisher
  include Mentioned
  include Notified

  layout false
  load_and_authorize_resource :inline_thread

  def create
    @comment = @inline_thread.comments.build(comment_params)
    @comment.commentable = @inline_thread.commentable
    @comment.user = current_user

    if @comment.save
      publish_event('comment.created', @comment.to_event_payload)
      broadcast_notifications(
        action: :create,
        notifiable: @comment,
        user: current_user
      )
    else
      head :unprocessable_entity
    end
  end

  private

  def project
    @project ||= @inline_thread.commentable.respond_to?(:project) ? @inline_thread.commentable.project : nil
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
