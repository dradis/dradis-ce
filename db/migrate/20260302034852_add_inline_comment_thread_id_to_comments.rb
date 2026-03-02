class AddInlineCommentThreadIdToComments < ActiveRecord::Migration[8.0]
  def change
    add_reference :comments, :inline_comment_thread,
      null: true,
      foreign_key: true,
      index: true
  end
end
