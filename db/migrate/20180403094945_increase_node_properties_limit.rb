class IncreaseNodePropertiesLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :nodes, :properties, :longtext
  end

  def down
    change_column :nodes, :properties, :text
  end
end
