class AddPropertiesToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :properties, :text
  end
end
