class InlineThreadsController < AuthenticatedController
  include EventPublisher
  include Notified

  layout false

  before_action :set_thread, only: [:show, :destroy]

  include Mentioned

  def index
    @threads = commentable.inline_threads
                           .includes(comments: :user)
                           .order(created_at: :asc)
  end

  def show
  end

  def create
    @thread = commentable.inline_threads.build(thread_params)
    @thread.user = current_user
    @thread.version_id = commentable.versions.last&.id

    if @thread.save
      if params[:comment].present? && params[:comment][:content].present?
        @comment = @thread.comments.build(
          content: params[:comment][:content],
          commentable: commentable,
          user: current_user
        )

        if @comment.save
          publish_event('comment.created', @comment.to_event_payload)
          broadcast_notifications(
            action: :create,
            notifiable: @comment,
            user: current_user
          )
        end
      end

      publish_event('inline_thread.created', @thread.to_event_payload)
    else
      head :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @thread
    @thread.destroy!
    publish_event('inline_thread.destroyed', @thread.to_event_payload)
  end

  private

  def commentable
    @commentable ||= begin
      if @thread
        @thread.commentable
      else
        commentable_class.find(comment_thread_params[:commentable_id])
      end
    end
  end

  def commentable_class
    if InlineCommentable.allowed_types.include?(comment_thread_params[:commentable_type])
      comment_thread_params[:commentable_type].constantize
    else
      raise 'Invalid commentable'
    end
  end

  def comment_thread_params
    params.require(:inline_thread).permit(:commentable_type, :commentable_id)
  end

  def project
    @project ||= commentable.respond_to?(:project) ? commentable.project : nil
  end

  def set_thread
    @thread = InlineThread.find(params[:id])
  end

  def thread_params
    params.require(:inline_thread).permit(
      :commentable_type, :commentable_id,
      anchor: [:type, :exact, :prefix, :suffix, :field_name, { position: [:start, :end] }]
    )
  end
end
