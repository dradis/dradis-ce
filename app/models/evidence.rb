class Evidence < ActiveRecord::Base
  include HasFields
  include RevisionTracking

  dradis_has_fields_for :content

  # -- Relationships --------------------------------------------------------
  belongs_to :issue, touch: true
  belongs_to :node, touch: true
  has_many :activities, as: :trackable


  # -- Callbacks ------------------------------------------------------------


  # -- Validations ----------------------------------------------------------
  validates :content, length: { maximum: 65535 }
  validates :issue, presence: true, associated: true
  validates :node, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------


  # -- Class Methods --------------------------------------------------------


  # -- Instance Methods -----------------------------------------------------

  def local_fields
    { 'Label' => node.try(:label) }
  end

end
