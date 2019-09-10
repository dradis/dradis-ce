class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.string :name
      t.references :node, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
