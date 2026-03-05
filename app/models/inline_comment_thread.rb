class InlineCommentThread < ApplicationRecord
  include Eventable

  REQUIRED_ANCHOR_KEYS = %w[exact position prefix suffix type].freeze

  serialize :anchor, coder: JSON

  enum :status, { open: 0, resolved: 1 }

  # -- Relationships --------------------------------------------------------
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :resolved_by, class_name: 'User', optional: true
  belongs_to :paper_trail_version,
    class_name: 'PaperTrail::Version',
    foreign_key: :version_id,
    optional: true
  has_many :comments, dependent: :destroy

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

  # -- Callbacks ------------------------------------------------------------
  before_validation :coerce_anchor_position

  # -- Validations ----------------------------------------------------------
  validates :anchor, presence: true
  validates :commentable, presence: true
  validate :anchor_schema_valid

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def resolve!(user)
    update!(status: :resolved, resolved_by: user, resolved_at: Time.current)
  end

  def reopen!(_user)
    update!(status: :open, resolved_by: nil, resolved_at: nil)
  end

  def quoted_text
    anchor&.dig('exact')
  end

  def outdated?
    return false if version_id.nil?

    latest_version = commentable.versions.where(event: 'update').last
    return false unless latest_version

    version_id < latest_version.id
  end

  def project
    commentable.project
  end

  def local_event_payload
    {
      anchor: anchor,
      commentable: {
        id: commentable.id,
        title: commentable.title
      },
      status: status
    }
  end

  private

  def coerce_anchor_position
    return if anchor.blank? || !anchor.is_a?(Hash)
    return unless anchor['position'].is_a?(Hash)

    %w[start end].each do |key|
      val = anchor['position'][key]
      if val.is_a?(String) && val =~ /\A\d+\z/
        anchor['position'][key] = val.to_i
      end
    end
  end

  def anchor_schema_valid
    return if anchor.blank?

    missing = REQUIRED_ANCHOR_KEYS - anchor.keys
    if missing.any?
      errors.add(:anchor, "missing required keys: #{missing.join(', ')}")
    end

    if anchor['position'].present?
      pos = anchor['position']
      unless pos.is_a?(Hash) &&
             pos['start'].to_s =~ /\A\d+\z/ &&
             pos['end'].to_s =~ /\A\d+\z/
        errors.add(:anchor, 'position must have integer start and end')
      end
    end
  end
end
