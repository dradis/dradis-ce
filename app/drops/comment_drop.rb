class CommentDrop < BaseDrop
  delegate :content, :created_at, :updated_at, to: :@record

  def user
    UserDrop.new(@record.user)
  end
end
