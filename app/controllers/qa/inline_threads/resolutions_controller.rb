class QA::InlineThreads::ResolutionsController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped

  before_action :set_issue
  before_action :set_thread

  layout false

  def create
    @thread.resolve!(current_user)
    track_activity(@thread, :resolve, current_user, current_project)
  end

  def destroy
    @thread.reopen!(current_user)
    track_activity(@thread, :reopen, current_user, current_project)
  end

  private

  def set_issue
    @issue = current_project.issues.ready_for_review.find(params[:issue_id])
  end

  def set_thread
    @thread = @issue.inline_comment_threads.find(params[:inline_thread_id])
  end
end
