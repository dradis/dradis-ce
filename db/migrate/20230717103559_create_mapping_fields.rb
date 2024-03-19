class CreateMappingFields < ActiveRecord::Migration[6.1]
  def change
    create_table :mapping_fields do |t|
      t.references :mapping, null: false, foreign_key: true
      t.string :source_field
      t.string :destination_field
      t.text :content

      t.timestamps
    end
  end
end
