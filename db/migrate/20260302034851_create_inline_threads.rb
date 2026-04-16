class CreateInlineThreads < ActiveRecord::Migration[8.0]
  def change
    create_table :inline_threads do |t|
      t.references :commentable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :anchor, null: false
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.references :version
      t.integer :status, default: 0, null: false
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :inline_threads, [:commentable_type, :commentable_id, :status],
      name: 'index_inline_threads_on_commentable_and_status'
  end
end
