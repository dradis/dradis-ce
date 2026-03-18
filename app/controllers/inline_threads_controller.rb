class InlineThreadsController < AuthenticatedController
  load_and_authorize_resource except: [:index]

  include EventPublisher
  # FIXME: @mentions are currently too tied to Comments
  #   we need to revisit and untangle - but we can't
  #   fully remove because we're half the way through
  #   the integration.
  include Mentioned
  include Notified

  layout false

  before_action :authorize_commentable
  before_action :require_comment, only: [:create]

  def new
    @commentable_type = inline_thread_params[:commentable_type]
    @commentable_id = inline_thread_params[:commentable_id]
    @anchor = inline_thread_params[:anchor]
  end

  def index
    @inline_threads = commentable.inline_threads
                           .includes(comments: :user)
                           .order(created_at: :asc)
  end

  def show
    @inline_thread.comments.includes(:user).load
  end

  def create
    @inline_thread = commentable.inline_threads.build(inline_thread_params_for_create)
    comment = @inline_thread.comments.first

    if @inline_thread.save
      publish_event('comment.created', comment.to_event_payload)
      broadcast_notifications(
        action: :create,
        notifiable: comment,
        user: current_user
      )
      publish_event('inline_thread.created', @inline_thread.to_event_payload)
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @inline_thread.destroy!
    publish_event('inline_thread.destroyed', @inline_thread.to_event_payload)
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
      if @inline_thread
        @inline_thread.commentable
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

  def inline_thread_params
    permitted = params.require(:inline_thread).permit(
      :commentable_type, :commentable_id, :anchor,
      comments_attributes: [:content]
    )
    # anchor arrives as a JSON string (from new/create) and must be parsed
    # back into a hash before being passed to the model.
    permitted.merge!(anchor: JSON.parse(permitted[:anchor])) if permitted[:anchor]

    permitted
  end

  def inline_thread_params_for_create
    inline_thread_params.merge(
      user: current_user,
      version_id: commentable.versions.last&.id
    ).tap do |p|
      p[:comments_attributes].each_value do |attrs|
        attrs.merge!(user: current_user, commentable: commentable)
      end
    end
  end

  def project
    @project ||= commentable.respond_to?(:project) ? commentable.project : nil
  end

  def require_comment
    if inline_thread_params.dig(:comments_attributes, '0', :content).blank?
      head :unprocessable_entity
    end
  end
end
