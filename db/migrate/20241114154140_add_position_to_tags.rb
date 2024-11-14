class AddPositionToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :position, :integer
  end
end
