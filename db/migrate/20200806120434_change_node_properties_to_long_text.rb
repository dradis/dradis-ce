class ChangeNodePropertiesToLongText < ActiveRecord::Migration[5.2]
  def change
    change_column :nodes, :properties, :text, limit: DB_MAX_TEXT_LENGTH
  end
end
