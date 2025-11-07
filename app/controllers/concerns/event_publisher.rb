module EventPublisher
  # Fires an event using ActiveSupport::Notifications and passes the event_record
  # payload, action, and user as the event payloads.
  #
  # event_name: String
  # event_record: Eventable model record
  #
  # Returns nil
  def publish(event_name, event_record)
    ActiveSupport::Notifications.instrument(
      event_name,
      event_record.to_payload.merge(
        action: action_name,
        user: {
          id: current_user.id,
          email: current_user.email,
          name: current_user.name
        }
      )
    )
  end
end
