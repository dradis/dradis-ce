class QA::InlineThreads::CommentsController < AuthenticatedController
  include EventPublisher
  include Mentioned
  include Notified
  include ProjectScoped

  before_action :set_issue
  before_action :set_thread

  layout false

  def create
    @comment = @thread.comments.build(comment_params)
    @comment.commentable = @issue
    @comment.user = current_user

    if @comment.save
      publish_event('comment.created', @comment.to_event_payload)
      broadcast_notifications(
        action: :create,
        notifiable: @comment,
        user: current_user
      )
    end
  end

  private

  def set_issue
    @issue = current_project.issues.ready_for_review.find(params[:issue_id])
  end

  def set_thread
    @thread = @issue.inline_comment_threads.find(params[:inline_thread_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
