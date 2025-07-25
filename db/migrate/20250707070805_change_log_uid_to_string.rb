class ChangeLogUidToString < ActiveRecord::Migration[7.2]
  def change
    change_column :logs, :uid, :string
  end
end
