module CommentsHelper
  def comment_path(comment)
    polymorphic_path(
      commentable_resource_array(comment.commentable),
      anchor: dom_id(comment)
    )
  end

  def commentable_path(comment)
    polymorphic_path(
      commentable_resource_array(comment.commentable)
    )
  end

  private

  def commentable_resource_array(commentable)
    if commentable.respond_to?(:node)
      [current_project, commentable.node, commentable]
    else
      [current_project, commentable]
    end
  end
end
