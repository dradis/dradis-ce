class ChangeEvidenceContentToLongText < ActiveRecord::Migration[6.1]
  def change
    change_column :evidence, :content, :text, limit: DB_MAX_TEXT_LENGTH
  end
end
