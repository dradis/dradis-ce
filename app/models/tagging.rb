class Tagging < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true, touch: true

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :tag,      associated: true, presence: true
  validates :taggable, associated: true, presence: true
  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
