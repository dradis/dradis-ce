class AddAuthorToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :author, :string
  end
end
