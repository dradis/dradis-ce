class IndexColumnsWithUniquenessValidations < ActiveRecord::Migration
  def change
    add_index :configurations, :name, unique: true
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], unique: true
  end
end
