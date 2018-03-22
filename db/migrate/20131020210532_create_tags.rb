class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name, index: true, null: false
      t.integer :taggings_count, default: 0, index: true, null: false

      t.timestamps
    end
  end
end
