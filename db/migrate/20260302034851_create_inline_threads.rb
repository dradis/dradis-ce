class CreateInlineThreads < ActiveRecord::Migration[8.0]
  def change
    create_table :inline_threads do |t|
      t.references :commentable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :anchor, null: false
      t.integer :version_id
      t.integer :status, default: 0, null: false
      t.integer :resolved_by_id
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :inline_threads, [:commentable_type, :commentable_id, :status],
      name: 'index_inline_threads_on_commentable_and_status'
    add_foreign_key :inline_threads, :users, column: :resolved_by_id
  end
end
