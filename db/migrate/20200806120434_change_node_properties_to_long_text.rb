class ChangeNodePropertiesToLongText < ActiveRecord::Migration[5.2]
  def change
    change_column :nodes, :properties, :text, limit: DB_REAL_MAX_LENGTH
  end
end
