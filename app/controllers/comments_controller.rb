class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier
  include ProjectScoped

  load_and_authorize_resource

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.save!
    websocket_event(@comment, 'create')
  end

  def update
    @comment.update_attributes!(comment_params)
    websocket_event(@comment, 'update')
  end

  def destroy
    @comment.destroy
    websocket_event(@comment, 'destroy')
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def websocket_event(action, comment)
    ActionCable.server.broadcast(
      'comment_channel',
      action: action,
      comment_feed_id: dom_id(comment.commentable),
      comment_id: comment.id,
    )
    head :no_content
  end
end
