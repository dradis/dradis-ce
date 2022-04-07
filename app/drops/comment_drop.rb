class CommentDrop < BaseDrop
  delegate :content, :created_at, :updated_at, to: :@record

  def user
    @record.user ? UserDrop.new(@record.user) : nil
  end

  ActiveSupport.run_load_hooks(:comment_drop, self)
end
