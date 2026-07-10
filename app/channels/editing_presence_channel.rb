class EditingPresenceChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  STREAM_NAME_FORMAT = /\Aediting_presence_\d+_(?<record_type>.+)_(?<record_id>\d+)\z/

  def subscribed
    stream_name = verified_stream_name_from_params
    match = stream_name && STREAM_NAME_FORMAT.match(stream_name)

    if match && authorized_record(match[:record_type], match[:record_id])
      @record_type = match[:record_type]
      @record_id = match[:record_id]

      stream_from stream_name

      EditingSession.purge_stale_for(record_type: @record_type, record_id: @record_id)
      EditingSession.find_or_create_by!(
        user: current_user,
        record_type: @record_type,
        record_id: @record_id
      )
    else
      reject
    end
  end

  def unsubscribed
    return unless @record_type

    EditingSession.where(
      user: current_user,
      record_type: @record_type,
      record_id: @record_id
    ).destroy_all
  end

  private

  def authorized_record(record_type, record_id)
    record = record_type.safe_constantize&.find_by(id: record_id)
    record if record && Ability.new(current_user).can?(:read, record)
  end
end
