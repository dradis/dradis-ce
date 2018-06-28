class CommentsController < AuthenticatedController
  include ActionView::RecordIdentifier

  before_action :find_commentable
  before_action :find_or_initialize_comment
  before_action :check_comment_author, only: [:update, :destroy]

  def create
    @comment.save
    redirect_to polymorphic_path(@commentable, anchor: dom_id(@comment))
  end

  def update
    @comment.update_attributes(comment_params)
    redirect_to polymorphic_path(@commentable, anchor: dom_id(@comment))
  end

  def destroy
    @comment.destroy
    redirect_to @commentable
  end

  private
  def check_comment_author
    head :forbidden unless @comment.user == current_user
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def find_commentable
    if params[:issue_id]
      @commentable = Issue.find(params[:issue_id])
    end

    @commentable
  end

  def find_or_initialize_comment
    if params[:id]
      @comment = Comment.find(params[:id])
    else
      @comment = Comment.new(comment_params)
      @comment.commentable = @commentable
      @comment.user = current_user
    end

    @comment
  end
end
