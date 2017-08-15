class CreateConfigurations < ActiveRecord::Migration[5.1]
  def self.up
    create_table :configurations do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
