class InlineCommentThread < ApplicationRecord
  include Eventable

  REQUIRED_ANCHOR_KEYS = %w[exact position prefix suffix type].freeze

  serialize :anchor, coder: JSON

  enum :status, { open: 0, resolved: 1 }

  # -- Relationships --------------------------------------------------------
  belongs_to :issue
  belongs_to :user
  belongs_to :resolved_by, class_name: 'User', optional: true
  belongs_to :paper_trail_version,
    class_name: 'PaperTrail::Version',
    foreign_key: :version_id,
    optional: true
  has_many :comments, dependent: :destroy

  # -- Callbacks ------------------------------------------------------------
  before_validation :coerce_anchor_position

  # -- Validations ----------------------------------------------------------
  validates :anchor, presence: true
  validates :issue, presence: true
  validate :anchor_schema_valid

  # -- Scopes ---------------------------------------------------------------
  scope :for_issue, ->(issue) { where(issue_id: issue.id) }

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

    latest_version = issue.versions.where(event: 'update').last
    return false unless latest_version

    version_id < latest_version.id
  end

  def project
    issue.project
  end

  def local_event_payload
    {
      anchor: anchor,
      issue: {
        id: issue.id,
        title: issue.title
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
