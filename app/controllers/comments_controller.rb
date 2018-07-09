class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier
  include ProjectScoped

  load_and_authorize_resource

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.save!
    ActionCable.server.broadcast(
      'comment_channel',
      action: 'create',
      comment_feed_id: dom_id(@comment.commentable),
      html: render_to_string(@comment), # TODO do we have to worry about XSS issues?
    )
    head :no_content
  end

  def update
    @comment.update_attributes!(comment_params)
    ActionCable.server.broadcast(
      'comment_channel',
      action: 'update',
      comment_feed_id: dom_id(@comment.commentable),
      comment_id: @comment.id,
      html: render_to_string(@comment), # TODO do we have to worry about XSS issues?
    )
    head :no_content
  end

  def destroy
    @comment.destroy
    redirect_to [@project, @comment.commentable]
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end
end
