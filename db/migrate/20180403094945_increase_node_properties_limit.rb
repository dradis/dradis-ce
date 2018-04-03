class IncreaseNodePropertiesLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :nodes, :properties, :text, limit: 4.gigabytes - 1
  end
end
