class CreateEditingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :editing_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.datetime :started_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.index [:record_type, :record_id]
      t.index [:user_id, :record_type, :record_id], unique: true, name: 'index_editing_sessions_uniqueness'
    end
  end
end
