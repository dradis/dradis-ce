class AddPropertiesToNodes < ActiveRecord::Migration[5.1]
  def change
    add_column :nodes, :properties, :text
  end
end
