class EditingSession < ApplicationRecord
  ALLOWED_RECORD_TYPES = %w[Issue].freeze
  STALE_AFTER = 1.day

  belongs_to :user
  belongs_to :record, polymorphic: true

  validates :record_type, presence: true, inclusion: { in: ALLOWED_RECORD_TYPES }

  scope :active, -> { where(started_at: STALE_AFTER.ago..) }
  scope :by_others, ->(user) { where.not(user: user) }
  scope :for_record, ->(record) {
    where(record_type: record.class.name, record_id: record.id)
  }
  scope :stale, -> { where(started_at: ...STALE_AFTER.ago) }

  def self.acquire(record_type:, record_id:, user:)
    purge_stale_for(record_type: record_type, record_id: record_id)
    create_or_find_by!(record_type: record_type, record_id: record_id, user: user)
  end

  def self.purge_stale_for(record_type:, record_id:)
    where(record_type: record_type, record_id: record_id).stale.destroy_all
  end
end
