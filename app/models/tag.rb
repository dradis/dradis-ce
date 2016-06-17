# This is the main Tag class. We can tag a number of models including:
#   * Issues
#
# Some tag names have a special meaning:
#   * If they start with # they are used  to categorise / group things (e.g #infrastructure)
#   * If they start with @ they are meant to ‘assign ownership’ of the model (e.g. @daniel)
#   * If they start with ! they define their own colour (e.g. !red needs to be coloured red, !4444dd should be a dark shade of blue).
#     - We require a 6-digit hex code (no 3-digit shortcut)
class Tag < ActiveRecord::Base
  # -- Relationships ----------------------------------------------------------
  has_many :taggings, dependent: :destroy

  # -- Callbacks --------------------------------------------------------------
  before_save :normalize_name

  # -- Validations ------------------------------------------------------------
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # -- Scopes -----------------------------------------------------------------


  # -- Class Methods ----------------------------------------------------------


  # -- Instance Methods -------------------------------------------------------

  # Returns a version of the tag's name suitable to present to the user:
  #  * If the tag name contains color details, they are stripped
  #  * The result is titleized
  def display_name()
    if self.name =~ /\A!([abcdef\d]{6})(_([[:word:]]+))?\z/
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
    name[/\A(![abcdef\d]{6})_[[:word:]]+?\z/,1].try(:gsub, "!", "#") || "#ccc"
  end

  private
  def normalize_name
    self[:name] = self.name.downcase
  end
end
