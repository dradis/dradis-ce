class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.string :author # FIXME: change to user id when we merge https://github.com/dradis/dradis-ce/pull/242
      t.text :content
      t.belongs_to :commentable, polymorphic: true

      t.timestamps
    end
  end
end
