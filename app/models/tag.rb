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

  # -- Virtual Attributes ----------------------------------------------------------
  attr_accessor :tag_name, :tag_color

  # -- Relationships ----------------------------------------------------------
  has_many :taggings, dependent: :destroy

  # -- Callbacks --------------------------------------------------------------
  before_save :normalize_name
  before_validation do
    self.name = "!#{self.tag_color[1..-1]}_#{self.tag_name}" unless self.tag_name.blank? and self.tag_color.blank?
  end

  # -- Validations ------------------------------------------------------------
  validates :name, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A!\h{6}_[[:word:]]+\z/ }
  # todo - this is a hack to get the taggable to work with the taggable_by_* methods
  validates :tag_name, presence: true
  validates :tag_color, presence: true, format: { with: /\A#\h{6}\z/ }

  # -- Scopes -----------------------------------------------------------------


  # -- Class Methods ----------------------------------------------------------


  # -- Instance Methods -------------------------------------------------------

  # Returns a version of the tag's name suitable to present to the user:
  #  * If the tag name contains color details, they are stripped
  #  * The result is titleized
  def display_name()
    if self.name =~ /\A!(\h{6})(_([[:word:]]+))?\z/
      if $3
        out = $3
      else
        out = $1
      end
    else
      out = self.name
    end
    return out.titleize
  end

  # Strips the tag's name and returns the color details if present
  # if no color information is found, returns a default value of #ccc
  def color()
    name[/\A(!\h{6})_[[:word:]]+?\z/,1].try(:gsub, "!", "#") || "#555"
  end

  private
  def normalize_name
    self[:name] = self.name.downcase
  end
end
