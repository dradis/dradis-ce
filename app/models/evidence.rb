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
  before_validation :create_issue_for_evidence

  # -- Validations ----------------------------------------------------------
  validates :content, length: { maximum: DB_MAX_TEXT_LENGTH }
  validates :issue, presence: true, associated: true
  validates :node, presence: true, associated: true

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

  def create_issue_for_evidence
    if self.issue_id.blank? && self.project.issues.blank?
      issue = Issue.create(
        text: "#[Title]#\nNew issue",
        node: self.project.issue_library,
        author: self.author
      )
  
      self.issue_id = issue.id
    end
  end
end
