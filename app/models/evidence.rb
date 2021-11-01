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

  # -- Validations ----------------------------------------------------------
  validates :content, length: { maximum: DB_MAX_TEXT_LENGTH }
  validates :issue, presence: true, associated: true
  validates :node, presence: true, associated: true

  validate :issue_cannot_be_on_another_project

  # -- Scopes ---------------------------------------------------------------


  # -- Class Methods --------------------------------------------------------


  # -- Instance Methods -----------------------------------------------------

  def local_fields
    {
      'Label' => node.try(:label),
      'Title' => issue.try(:title)
    }
  end

  private

  def issue_cannot_be_on_another_project
    return unless node && issue

    if node.project.id != issue.project.id
      errors.add(:issue, 'cannot be on another project')
    end
  end
end
