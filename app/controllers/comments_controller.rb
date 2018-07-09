class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier
  include ProjectScoped

  load_and_authorize_resource

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.save!
    send_to_websockets(@comment, 'create')
  end

  def update
    @comment.update_attributes!(comment_params)
    send_to_websockets(@comment, 'update')
  end

  def destroy
    @comment.destroy
    send_to_websockets(@comment, 'destroy')
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def send_to_websockets(comment, action)
    ActionCable.server.broadcast(
      'comment_channel',
      action: action,
      comment_feed_id: dom_id(comment.commentable),
      comment_id: comment.id,
      html: render_to_string(comment), # TODO do we have to worry about XSS here?
    )
    head :no_content
  end
end
