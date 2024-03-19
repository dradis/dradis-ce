class CreateMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :mappings do |t|
      t.string :component
      t.string :source
      t.string :destination

      t.timestamps
    end
  end
end
