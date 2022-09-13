# This is the main Tag class. We can tag a number of models including:
#   * Issues
#
# Some tag names have a special meaning:
#   * If they start with # they are used  to categorise / group things (e.g #infrastructure)
#   * If they start with @ they are meant to ‘assign ownership’ of the model (e.g. @daniel)
#   * If they start with ! they define their own colour (e.g. !red needs to be coloured red, !4444dd should be a dark shade of blue).
#     - We require a 6-digit hex code (no 3-digit shortcut)
class Tag < ApplicationRecord
  DEFAULT_TAGS = %w[
    !9467bd_critical
    !d62728_high
    !ff7f0e_medium
    !6baed6_low
    !2ca02c_info
  ].freeze

  # -- Relationships ----------------------------------------------------------
  has_many :taggings, dependent: :destroy

  # -- Callbacks --------------------------------------------------------------
  before_save :normalize_name

  # -- Validations ------------------------------------------------------------
  validates :name, 
    presence: true, 
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-zA-Z]+\z/ }
  validates :color, 
    presence: true, 
    uniqueness: { case_sensitive: false },
    format: { with: /\A#\h{6}/ }

  # -- Scopes -----------------------------------------------------------------


  # -- Class Methods ----------------------------------------------------------


  # -- Instance Methods -------------------------------------------------------

  # Returns a version of the tag's name suitable to present to the user:
  #  * The name is titleized
  def display_name
    name.titleize
  end

  private
  def normalize_name
    self[:name] = self.name.downcase
  end
end
