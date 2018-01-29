class IndexForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_index :evidence, :node_id
    add_index :evidence, :issue_id
    add_index :nodes, :type_id
    add_index :nodes, :parent_id
    add_index :notes, :node_id
    add_index :notes, :category_id
  end
end
