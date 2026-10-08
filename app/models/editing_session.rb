class EditingSession < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :user
  belongs_to :record, polymorphic: true

  # -- Validations ----------------------------------------------------------
  # Evaluated lazily: Lockable.allowed_types is populated as each model is
  # loaded and includes the concern, which may happen after this class.
  validates :record_type, presence: true, inclusion: { in: ->(_) { Lockable.allowed_types } }

  # -- Class Methods -----------------------------------------------------
  def self.acquire!(record_type:, record_id:, user:)
    purge_stale_for(record_type: record_type, record_id: record_id)
    create_or_find_by!(record_type: record_type, record_id: record_id) { |session| session.user = user }
  end

  def self.expiry
    Configuration.editing_session_expiry.minutes
  end

  # FIXME - ISSUE/NOTE INHERITANCE
  # `find_by(record: record)` won't work here: Issue is an STI subclass of Note,
  # so Rails' polymorphic query would look up record_type: 'Note' (the base
  # class), not 'Issue' (what we actually store, see .acquire! below).
  # The uniqueness index on [record_type, record_id] guarantees at most one
  # session per record, so this returns a single record rather than a relation.
  def self.for_record(record)
    find_by(record_type: record.class.name, record_id: record.id)
  end

  def self.purge_stale_for(record_type:, record_id:)
    where(record_type: record_type, record_id: record_id, created_at: ...expiry.ago).destroy_all
  end

  # -- Instance Methods -----------------------------------------------------
  def active?
    created_at >= self.class.expiry.ago
  end
end
