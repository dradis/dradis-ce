class InlineThread < ApplicationRecord
  include Eventable
  include InlineThread::Anchor

  enum :status, [:open, :resolved]

  # -- Relationships --------------------------------------------------------
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :resolved_by, class_name: 'User', optional: true
  belongs_to :paper_trail_version,
    class_name: 'PaperTrail::Version',
    foreign_key: :version_id,
    optional: true
  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :comments

  # Because Issue descends from Note but doesn't use STI, Rails's default
  # polymorphic setter will set 'commentable_type' to 'Note' when you pass an
  # Issue. Override the default behaviour here for issues:
  #
  # FIXME - ISSUE/NOTE INHERITANCE
  def commentable=(new_commentable)
    super
    self.commentable_type = 'Issue' if new_commentable.is_a?(Issue)
    new_commentable
  end

  delegate :project, to: :commentable

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  
  validates :commentable, presence: true

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def local_event_payload
    {
      anchor: anchor,
      commentable: {
        id: commentable.id,
        title: commentable.title
      },
      project: {
        id: project.id,
        name: project.name
      },
      status: status
    }
  end

  def outdated?
    return false if version_id.nil?

    latest_version = commentable.versions.where(event: 'update').last
    return false unless latest_version

    version_id < latest_version.id
  end

  def reopen!(_user)
    update!(status: :open, resolved_by: nil, resolved_at: nil)
  end

  def resolve!(user)
    update!(status: :resolved, resolved_by: user, resolved_at: Time.current)
  end
end
