class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier
  include ProjectScoped

  before_action :set_comment, except: [:create]
  before_action :check_comment_author, only: [:update, :destroy]

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.save
    redirect_to polymorphic_path([@project, @comment.commentable], anchor: dom_id(@comment))
  end

  def update
    @comment.update_attributes(comment_params)
    redirect_to polymorphic_path([@project, @comment.commentable], anchor: dom_id(@comment))
  end

  def destroy
    @comment.destroy
    redirect_to [@project, @comment.commentable]
  end

  private
  def check_comment_author
    head :forbidden unless @comment.user == current_user
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
