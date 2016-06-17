class Evidence < ActiveRecord::Base
  include HasFields

  dradis_has_fields_for :content
  has_paper_trail

  # -- Relationships --------------------------------------------------------
  belongs_to :issue
  belongs_to :node
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
