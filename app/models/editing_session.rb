class EditingSession < ApplicationRecord
  belongs_to :user
  belongs_to :record, polymorphic: true

  # Evaluated lazily: Lockable.allowed_types is populated as each model is
  # loaded and includes the concern, which may happen after this class.
  validates :record_type, presence: true, inclusion: { in: ->(_) { Lockable.allowed_types } }

  scope :active, -> { where(created_at: stale_after.ago..) }
  scope :by_others, ->(user) { where.not(user: user) }
  # `where(record: record)` won't work here: Issue is an STI subclass of Note,
  # so Rails' polymorphic query would look up record_type: 'Note' (the base
  # class), not 'Issue' (what we actually store, see .acquire! below).
  scope :for_record, ->(record) {
    where(record_type: record.class.name, record_id: record.id)
  }
  scope :stale, -> { where(created_at: ...stale_after.ago) }

  def self.acquire!(record_type:, record_id:, user:)
    purge_stale_for(record_type: record_type, record_id: record_id)
    create_or_find_by!(record_type: record_type, record_id: record_id) { |session| session.user = user }
  end

  def self.purge_stale_for(record_type:, record_id:)
    where(record_type: record_type, record_id: record_id).stale.destroy_all
  end

  def self.stale_after
    Configuration.editing_session_stale_after.minutes
  end
end
