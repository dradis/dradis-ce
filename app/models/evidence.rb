class Evidence < ApplicationRecord
  include Commentable
  include HasFields
  include RevisionTracking
  include Subscribable

  dradis_has_fields_for :content

  # -- Relationships --------------------------------------------------------
  belongs_to :issue, touch: true
  belongs_to :node, touch: true
  has_many :activities, as: :trackable

  delegate :project, to: :node

  # -- Callbacks ------------------------------------------------------------
  before_save { self[:rendered_content] = nil }
  after_touch  { update_column(:rendered_content, nil) }

  # -- Validations ----------------------------------------------------------
  validates :content, length: { maximum: DB_MAX_TEXT_LENGTH }
  validates :issue, presence: true, associated: true
  validates :node, presence: true, associated: true

  validate :validate_issue_project

  # -- Scopes ---------------------------------------------------------------


  # -- Class Methods --------------------------------------------------------


  # -- Instance Methods -----------------------------------------------------

  def local_fields
    {
      'Label' => node.try(:label),
      'Title' => issue&.raw_fields&.fetch('Title', nil)
    }
  end

  private

  def validate_issue_project
    return unless node && issue

    if project.id != issue.project.id
      errors.add(:issue, 'is invalid')
    end
  end
end
