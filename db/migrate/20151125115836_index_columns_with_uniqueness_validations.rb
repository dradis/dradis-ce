class IndexColumnsWithUniquenessValidations < ActiveRecord::Migration
  def change
    add_index :configurations, :name, unique: true
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], unique: true
    # Can't add 'unique: true' because the validation is *case-insensitive*
    # uniqueness. Does MySQL support a non-case-sensitive unique index? Even if
    # it does, is there an easy way to add it via ActiveRecord?
    add_index :tags, :name
  end
end
