class CommentsController < AuthenticatedController
  layout false

  include ActivityTracking
  include Notified

  load_and_authorize_resource except: [:index]

  before_action :find_mentionable_users, only: [:index, :create, :update]
  before_action :validate_commentable, only: [:index, :create]

  helper_method :commentable, :comments

  def index; end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment, project: project)
      broadcast_notifications(
        action: :create,
        notifiable: @comment,
        user: current_user
      )
    end
  end

  def update
    if @comment.update(comment_params)
      track_updated(@comment, project: project)
    end
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment, project: project)
    end
  end

  private

  def comment_params
    case params[:action]
    when 'index'
      params.permit(:commentable_id, :commentable_type)
    when 'create', 'update'
      params.require(:comment).permit(:content, :commentable_type, :commentable_id)
    else
      raise 'Invalid action'
    end
  end

  def commentable
    @commentable ||= begin
      case params[:action]
      when 'index', 'create'
        Comment.new(
          commentable_type: comment_params[:commentable_type],
          commentable_id: comment_params[:commentable_id]
        ).commentable
      when 'update', 'destroy'
        @comment.commentable
      else
        raise 'Invalid action'
      end
    end
  end

  def comments
    @comments ||= commentable&.comments&.includes(:user)
  end

  def find_mentionable_users
    @mentionable_users ||= begin
      project.testers_for_mentions
    end
  end

  def project
    # Using defined? to check for instance variable because @project
    # can be nil.
    return @project if defined?(@project)

    @project =
      if commentable.respond_to?(:project)
        commentable.project
      else
        nil
      end
  end

  def validate_commentable
    # Because a user can have many comments, we have to check the type to not
    # cause any information leakage. We also check if commentable can respond
    # to the #comments method instead of whitelisting so that we don't have to
    # hard code plugin models here.
    if commentable.is_a?(User) || !commentable.respond_to?(:comments)
      raise 'Invalid commentable'
    end

    if commentable.respond_to?(:project)
      authorize! :use, commentable.project
    else
      authorize! :read, commentable
    end
  end
end
