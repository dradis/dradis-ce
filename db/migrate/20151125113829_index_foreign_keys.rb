class IndexForeignKeys < ActiveRecord::Migration
  def change
    add_index :evidence, :node_id
    add_index :evidence, :issue_id
    add_index :nodes, :type_id
    add_index :nodes, :parent_id
    add_index :notes, :node_id
    add_index :notes, :category_id
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
end
