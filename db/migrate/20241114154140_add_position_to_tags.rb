class AddPositionToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :position, :integer

    Tag.transaction do
      Tag.unscoped.each_with_index(1) do |tag, index|
        tag.update_attribute(:position, index)
      end
    end
  end
end
