class CommentsController < AuthenticatedController
  # Load @comment first
  load_and_authorize_resource

  include ActivityTracking
  include Mentioned

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
      if commentable.respond_to?(:project)
        commentable.project
      else
        nil
      end
  end
end
