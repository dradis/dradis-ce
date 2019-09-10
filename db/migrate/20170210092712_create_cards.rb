class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :name
      t.text :description
      t.date :due_date
      t.integer :list_id, index: true
      t.integer :previous_id, index: true

      t.timestamps null: false
    end
  end
end
