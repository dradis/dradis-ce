class AddColorToTag < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :color, :string, default: '#555555', null: false
    Tag.all.each do |tag|
      color, name = tag.name.split('_')
      color = color.try(:gsub, "!", "#")
      tag.update(name: name, color: color)
    end
  end
end
