class EditingPresenceChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  ALLOWED_RECORD_TYPES = %w[Issue].freeze

  def subscribed
    stream_name = verified_stream_name_from_params
    match = stream_name && EditingSession.parse_stream_name(stream_name)

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
    return unless ALLOWED_RECORD_TYPES.include?(record_type)

    record = record_type.constantize.find_by(id: record_id)
    record if record && Ability.new(current_user).can?(:read, record)
  end
end
