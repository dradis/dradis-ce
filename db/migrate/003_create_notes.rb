class CreateNotes < ActiveRecord::Migration[5.1]
  def self.up
    create_table :notes do |t|
      t.string :author
      t.text :text
      t.integer :node_id
      t.integer :category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
