class ChangeNodePropertiesToLongText < ActiveRecord::Migration[5.2]
  TEXT_BYTES = 1_073_741_823

  def change
    change_column :nodes, :properties, :text, limit: TEXT_BYTES
  end
end
