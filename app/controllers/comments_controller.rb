class CommentsController < AuthenticatedController
  layout false

  include ActivityTracking
  include Commented
  include Mentioned

  load_and_authorize_resource except: [:index]

  def index; end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment, project: project)
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
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def project
    # Using defined? to check for instance variable because @project
    # can be nil.
    return @project if defined?(@project)

    @project =
      if @comment.commentable.respond_to?(:project)
        @comment.commentable.project
      else
        nil
      end
  end
end
