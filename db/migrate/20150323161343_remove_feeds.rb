class RemoveFeeds < ActiveRecord::Migration[5.1]
  def change
    drop_table :feeds
  end
end
