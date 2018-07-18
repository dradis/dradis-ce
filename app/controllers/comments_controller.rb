class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier
  include ActivityTracking
  include ProjectScoped

  load_and_authorize_resource

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      track_created(@comment)
    end

    redirect_to polymorphic_path([@project, @comment.commentable], anchor: dom_id(@comment))
  end

  def update
    if @comment.update_attributes(comment_params)
      track_updated(@comment)
    end

    redirect_to polymorphic_path([@project, @comment.commentable], anchor: dom_id(@comment))
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment)
    end

    redirect_to [@project, @comment.commentable]
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end
end
