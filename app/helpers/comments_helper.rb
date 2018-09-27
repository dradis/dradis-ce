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
    # FIXME - ISSUE/NOTE INHERITANCE
    # Would like to use only `commentable.respond_to?(:node)` here, but
    # that would return a wrong path for issues
    if commentable.respond_to?(:node) && !commentable.is_a?(Issue)
      [current_project, commentable.node, commentable]
    else
      [current_project, commentable]
    end
  end
end
