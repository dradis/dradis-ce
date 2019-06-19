class RenameTextToContentInNotes < ActiveRecord::Migration[5.1]
  def change
    rename_column :notes, :text, :content
  end
end
