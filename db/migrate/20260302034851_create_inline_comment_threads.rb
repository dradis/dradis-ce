class CreateInlineCommentThreads < ActiveRecord::Migration[8.0]
  def change
    create_table :inline_comment_threads do |t|
      t.references :issue, null: false
      t.references :user, null: false, foreign_key: true
      t.text :anchor, null: false
      t.integer :version_id
      t.integer :status, default: 0, null: false
      t.integer :resolved_by_id
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :inline_comment_threads, [:issue_id, :status]
    add_foreign_key :inline_comment_threads, :users, column: :resolved_by_id
  end
end
