class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :content

      t.references :commentable, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end
