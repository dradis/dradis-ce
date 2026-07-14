class EditingSession < ApplicationRecord
  STALE_AFTER = 1.day
  STREAM_NAME_FORMAT = /\Aediting_presence_\d+_(?<record_type>.+)_(?<record_id>\d+)\z/

  belongs_to :user
  belongs_to :record, polymorphic: true

  validates :record_type, presence: true
  validates :record_id, presence: true

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

  def self.parse_stream_name(stream_name)
    STREAM_NAME_FORMAT.match(stream_name)
  end

  private

  def broadcast_presence
    editors = EditingSession.where(
      record_type: record_type,
      record_id: record_id
    ).active.includes(:user).map(&:user)

    editors.each do |editor|
      Turbo::StreamsChannel.broadcast_update_to(
        editing_presence_stream_for(editor),
        target: 'editing-presence-editors',
        partial: 'shared/editing_presence',
        locals: { editors: editors - [editor] }
      )
    end
  end

  def editing_presence_stream_for(user)
    "editing_presence_#{user.id}_#{record_type}_#{record_id}"
  end
end
