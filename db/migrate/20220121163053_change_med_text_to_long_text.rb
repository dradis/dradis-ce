class ChangeMedTextToLongText < ActiveRecord::Migration[6.1]
  def up
    change_column :active_storage_blobs, :metadata, :text
    change_column :cards, :description, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :comments, :content, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :evidence, :content, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :logs, :text, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :nodes, :properties, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :notes, :text, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :users, :preferences, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
    change_column :versions, :object, :text, limit: ApplicationRecord::DB_MAX_TEXT_LENGTH
  end

  def down
    # NoOp
  end
end
