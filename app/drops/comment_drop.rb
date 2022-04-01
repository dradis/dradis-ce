class CommentDrop < BaseDrop
  delegate :content, to: :@record
end
