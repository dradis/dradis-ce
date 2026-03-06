class InlineThreadsController < AuthenticatedController
  load_and_authorize_resource

  include EventPublisher
  # FIXME: @mentions are currently too tied to Comments
  #   we need to revisit and untangle - but we can't
  #   fully remove because we're half the way through
  #   the integration.
  include Mentioned
  include Notified

  layout false

  before_action :authorize_commentable


  def index
    @threads = commentable.inline_threads
                           .includes(comments: :user)
                           .order(created_at: :asc)
  end

  def show
  end

  def create
    @thread = commentable.inline_threads.build(inline_thread_params)
    @thread.user = current_user
    @thread.version_id = commentable.versions.last&.id

    if @thread.save
      if comment_params.present? && comment_params[:content].present?
        @comment = @thread.comments.build(
          content: comment_params[:content],
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
    @thread.destroy!
    publish_event('inline_thread.destroyed', @thread.to_event_payload)
  end

  private

  def authorize_commentable
    if project
      authorize! :use, project
    else
      authorize! :show, commentable
    end
  end

  def commentable
    @commentable ||= begin
      if @thread
        @thread.commentable
      else
        commentable_class.find(inline_thread_params[:commentable_id])
      end
    end
  end

  def commentable_class
    if InlineCommentable.allowed_types.include?(inline_thread_params[:commentable_type])
      inline_thread_params[:commentable_type].constantize
    else
      raise 'Invalid commentable'
    end
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def inline_thread_params
    params.require(:inline_thread).permit(
      :commentable_type, :commentable_id,
      anchor: [:type, :exact, :prefix, :suffix, :field_name, { position: [:start, :end] }]
    )
  end

  def project
    @project ||= commentable.respond_to?(:project) ? commentable.project : nil
  end
end
