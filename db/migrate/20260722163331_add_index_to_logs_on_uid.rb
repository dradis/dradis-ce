class AddIndexToLogsOnUid < ActiveRecord::Migration[8.0]
  def change
    add_index :logs, :uid
  end
end
