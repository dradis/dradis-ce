class ChangeEvidenceContentToLongText < ActiveRecord::Migration[6.1]
  def up
    change_column :evidence, :content, :text, limit: DB_REAL_MAX_LENGTH
  end

  def down
    change_column :evidence, :content, :text, limit: DB_MAX_TEXT_LENGTH
  end
end
