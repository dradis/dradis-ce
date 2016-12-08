class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true, touch: true

  validates :tag,      associated: true, presence: true
  validates :taggable, associated: true, presence: true
  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]
end
