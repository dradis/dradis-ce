class CreateVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object,    :limit => DB_REAL_MAX_LENGTH
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
