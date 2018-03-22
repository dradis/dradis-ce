class CreateTaggings < ActiveRecord::Migration[5.1]
  def change
    create_table :taggings do |t|
      t.references :tag, :index => true
      t.references :taggable, :polymorphic => true, :index => true

      t.timestamps
    end
  end
end
