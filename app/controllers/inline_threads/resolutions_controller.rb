class InlineThreads::ResolutionsController < AuthenticatedController
  include EventPublisher

  layout false

  before_action :set_thread

  def create
    @thread.resolve!(current_user)
    publish_event('inline_comment_thread.resolved', @thread.to_event_payload)
  end

  def destroy
    @thread.reopen!(current_user)
    publish_event('inline_comment_thread.reopened', @thread.to_event_payload)
  end

  private

  def project
    @project ||= @thread.commentable.respond_to?(:project) ? @thread.commentable.project : nil
  end

  def set_thread
    @thread = InlineCommentThread.find(params[:inline_thread_id])
  end
end
