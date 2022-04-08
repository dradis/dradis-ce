class CommentDrop < BaseDrop
  delegate :content, :created_at, :updated_at, to: :@record

  def user
    @record.user ? UserDrop.new(@record.user) : nil
  end
end
