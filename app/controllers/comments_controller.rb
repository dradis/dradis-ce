class CommentsController < AuthenticatedController
  include ActivityTracking
  include ProjectScoped
  include Commented

  load_and_authorize_resource

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment)
    end
  end

  def update
    if @comment.update_attributes(comment_params)
      track_updated(@comment)
    end
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment)
    end
  end

  private

  # This is cheeky code to make mentions work from concerns/commented
  def comments
    [@comment]
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end
end
