module CommentsHelper
  def comment_path(comment)
    commentable = comment.commentable
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue' FIXME - ISSUE/NOTE INHERITANCE
    case commentable
    when Issue || !is_a?(Note)
      polymorphic_path([current_project, commentable], anchor: dom_id(comment))
    when Note
      polymorphic_path(
        [current_project, commentable.node, commentable],
        anchor: dom_id(comment)
      )
    end
  end

  def commentable_path(comment)
    commentable = comment.commentable
    # Note - 'when Issue' must go ABOVE 'when Note', or all Issues will match
    # 'Note' before they can reach 'Issue' FIXME - ISSUE/NOTE INHERITANCE
    case commentable
    when Issue || !is_a?(Note)
      polymorphic_path([current_project, commentable])
    when Note
      polymorphic_path([current_project, commentable.node, commentable])
    end
  end
end
