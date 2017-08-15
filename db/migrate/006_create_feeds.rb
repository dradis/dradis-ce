class CreateFeeds < ActiveRecord::Migration[5.1]
  def self.up
    create_table :feeds do |t|
      t.string :action
      t.string :user
      t.datetime :actioned_at
      t.string :resource
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end
