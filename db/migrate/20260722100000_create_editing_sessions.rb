class CreateEditingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :editing_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false, index: false
      t.datetime :created_at, null: false

      t.index [:record_type, :record_id], unique: true, name: 'index_editing_sessions_uniqueness'
    end
  end
end
