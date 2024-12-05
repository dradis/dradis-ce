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

  acts_as_list

  # -- Relationships ----------------------------------------------------------
  has_many :taggings, dependent: :destroy

  def project
    # dummy project; this makes Tags's interface more similar to how it is
    # in Pro and makes it easier to deal with tag in URL helpers
    @project ||= Project.new
  end

  def project=(new_project); end

  # -- Callbacks --------------------------------------------------------------
  before_save :normalize_name

  # -- Validations ------------------------------------------------------------
  validates :name,
  presence: true,
  uniqueness: { case_sensitive: false } ,
  format: {
    with: /\A(!\h{6})_[a-zA-Z]+?\z/, message: 'is invalid: Numbers and special characters are not permitted.'
  }

  # -- Scopes -----------------------------------------------------------------
  default_scope { order(:position) }

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
    name[/\A(!\h{6})_[[:word:]]+?\z/, 1].try(:gsub, '!', '#') || '#555'
  end

  private
  def normalize_name
    self[:name] = self.name.downcase
  end
end
