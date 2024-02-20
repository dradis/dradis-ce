class MappingField < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :mapping

  # -- Callbacks ------------------------------------------------------------
  #
  # -- Validations ----------------------------------------------------------
  validates :content, presence: true
  validates :destination_field,
    presence: true,
    uniqueness: { scope: [:mapping_id, :source_field], case_sensitive: false }
  validates :source_field, presence: true

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
end
