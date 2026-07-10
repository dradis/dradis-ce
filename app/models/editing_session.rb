class EditingSession < ApplicationRecord
  STALE_AFTER = 1.day

  belongs_to :user

  validates :record_type, presence: true
  validates :record_id, presence: true
  validates :user_id, uniqueness: { scope: [:record_type, :record_id] }

  after_commit :broadcast_presence, on: [:create, :destroy]

  scope :active, -> { where(started_at: STALE_AFTER.ago..) }
  scope :by_others, ->(user) { where.not(user: user) }
  scope :for_record, ->(record) {
    where(record_type: record.class.name, record_id: record.id)
  }
  scope :stale, -> { where(started_at: ...STALE_AFTER.ago) }

  def self.purge_stale_for(record_type:, record_id:)
    where(record_type: record_type, record_id: record_id).stale.destroy_all
  end

  private

  def broadcast_presence
    siblings = EditingSession.where(
      record_type: record_type,
      record_id: record_id
    ).includes(:user).to_a

    siblings.each do |session|
      others = siblings.reject { |sibling| sibling.user_id == session.user_id }.map(&:user)

      Turbo::StreamsChannel.broadcast_update_to(
        editing_presence_stream_for(session.user),
        target: 'editing-presence-editors',
        partial: 'shared/editing_presence',
        locals: { editors: others }
      )
    end
  end

  def editing_presence_stream_for(user)
    "editing_presence_#{user.id}_#{record_type}_#{record_id}"
  end
end
