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

    redirect_to_comment(@comment)
  end

  def update
    if @comment.update_attributes(comment_params)
      track_updated(@comment)
    end

    redirect_to_comment(@comment)
  end

  def destroy
    if @comment.destroy
      track_destroyed(@comment)
    end

    redirect_to_comment(@comment)
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def redirect_to_comment(comment)
    if comment.persisted? && !request.referrer.nil?
      request.env['HTTP_REFERER'] += "##{dom_id(comment)}"
    end

    redirect_back fallback_location: root_path
  end
end
