class InlineThreads::CommentsController < AuthenticatedController
  include EventPublisher
  include Mentioned
  include Notified

  layout false

  before_action :set_thread

  def create
    @comment = @thread.comments.build(comment_params)
    @comment.commentable = @thread.commentable
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
    @project ||= @thread.commentable.respond_to?(:project) ? @thread.commentable.project : nil
  end

  def set_thread
    @thread = InlineThread.find(params[:inline_thread_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
