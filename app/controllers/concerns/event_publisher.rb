module EventPublisher
  # Fires an event using ActiveSupport::Notifications and passes the payload,
  # action, and user as the event payloads.
  #
  # name: String. Name of the event
  # payload: Hash. Payload to publish along with the event
  #
  # Returns nil
  def publish_event(name, payload)
    ActiveSupport::Notifications.instrument(
      name,
      payload.merge(event_action_payload)
    )
  end

  def event_action_payload
    {
      action: action_name,
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name
      }
    }
  end
end
