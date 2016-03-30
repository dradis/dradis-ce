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

  # searches evidences using case insensitive LIKE
  # returns list of evidences matches orered by updated_at desc
  def self.search(term:)
    where("content LIKE :term", term: "%#{term}%")
      .select(:id, :content, :updated_at)
      .order(updated_at: :desc)
  end

  # -- Instance Methods -----------------------------------------------------

  def local_fields
    { 'Label' => node.try(:label) }
  end

end
