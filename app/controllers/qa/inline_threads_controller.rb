class QA::InlineThreadsController < AuthenticatedController
  include ActivityTracking
  include Mentioned
  include Notified
  include ProjectScoped

  before_action :set_issue
  before_action :set_thread, only: [:destroy]

  layout false

  def index
    @threads = @issue.inline_comment_threads
                     .includes(comments: :user)
                     .order(created_at: :asc)
  end

  def create
    @thread = @issue.inline_comment_threads.build(thread_params)
    @thread.user = current_user
    @thread.version_id = @issue.versions.last&.id

    if @thread.save
      if params[:comment].present? && params[:comment][:content].present?
        @comment = @thread.comments.build(
          content: params[:comment][:content],
          commentable: @issue,
          user: current_user
        )

        if @comment.save
          track_created(@comment, project: current_project)
          broadcast_notifications(
            action: :create,
            notifiable: @comment,
            user: current_user
          )
        end
      end

      track_created(@thread, project: current_project)
    end
  end

  def destroy
    authorize! :destroy, @thread
    @thread.destroy!
    track_destroyed(@thread, project: current_project)
  end

  private

  def set_issue
    @issue = current_project.issues.ready_for_review.find(params[:issue_id])
  end

  def set_thread
    @thread = @issue.inline_comment_threads.find(params[:id])
  end

  def thread_params
    params.require(:inline_comment_thread).permit(
      anchor: [:type, :exact, :prefix, :suffix, :field_name, { position: [:start, :end] }]
    )
  end
end
