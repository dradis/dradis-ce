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
  validates :name, presence: true, uniqueness: { case_sensitive: false },
    format: { with: /\A(!\h{6}(_([[:word:]]+))?|#[[:word:]]|@[[:word:]])\z/ }

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

  def display_name=(new_display_name)
    self.name.gsub!(/\A!(\h{6})_[[:word:]]+?\z/, "!\\1_#{new_display_name}")
  end

  # Strips the tag's name and returns the color details if present
  # if no color information is found, returns a default value of #ccc
  def color()
    name[/\A(!\h{6})_[[:word:]]+?\z/,1].try(:gsub, "!", "#") || '#cccccc'
  end

  def color=(new_color)
    new_color = new_color.tr('#', '')

    self.name.gsub!(/\A!(\h{6})_([[:word:]]+)?\z/, "!#{new_color}_\\2")
  end

  private
  def normalize_name
    self[:name] = self.name.downcase
  end
end
