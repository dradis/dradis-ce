class QA::InlineThreads::ResolutionsController < AuthenticatedController
  include EventPublisher
  include ProjectScoped

  before_action :set_issue
  before_action :set_thread

  layout false

  def create
    @thread.resolve!(current_user)
    publish_event('inline_comment_thread.resolved', @thread.to_event_payload)
  end

  def destroy
    @thread.reopen!(current_user)
    publish_event('inline_comment_thread.reopened', @thread.to_event_payload)
  end

  private

  def set_issue
    @issue = current_project.issues.ready_for_review.find(params[:issue_id])
  end

  def set_thread
    @thread = @issue.inline_comment_threads.find(params[:inline_thread_id])
  end
end
