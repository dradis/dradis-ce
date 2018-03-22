class CreateLogs < ActiveRecord::Migration[5.1]
  def self.up
    create_table :logs do |t|
      t.integer :uid
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
