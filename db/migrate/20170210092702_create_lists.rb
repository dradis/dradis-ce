class CreateLists < ActiveRecord::Migration[5.0]
  def change
    create_table :lists do |t|
      t.string :name
      t.integer :board_id, index: true
      t.integer :previous_id, index: true

      t.timestamps
    end
  end
end
