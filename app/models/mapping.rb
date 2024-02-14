class Mapping < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  has_many :mapping_fields, dependent: :destroy

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :component, presence: true
  validates :source, presence: true

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
end
