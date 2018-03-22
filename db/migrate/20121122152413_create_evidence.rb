class CreateEvidence < ActiveRecord::Migration[5.1]
  def change
    create_table :evidence do |t|
      t.integer :node_id
      t.integer :issue_id
      t.text :content
      t.string :author

      t.timestamps
    end
  end
end
