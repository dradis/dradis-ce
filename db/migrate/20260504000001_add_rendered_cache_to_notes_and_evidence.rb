class AddRenderedCacheToNotesAndEvidence < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :rendered_text, :text
    add_column :evidence, :rendered_content, :text
  end
end
