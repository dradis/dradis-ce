class AddPostionToNode < ActiveRecord::Migration[5.1]
  def change
    add_column :nodes, :position, :integer
  end
end
