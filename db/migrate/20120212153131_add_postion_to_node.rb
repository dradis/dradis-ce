class AddPostionToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :position, :integer
  end
end
