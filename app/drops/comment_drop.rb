class CommentDrop < BaseDrop
  delegate :content, :created_at, :updated_at, :user, to: :@record
end
