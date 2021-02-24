module Notified
  protected

  def broadcast_notifications(action:, actor:, notifiable:)
    NotificationsBroadcastJob.perform_later(
      action: action.to_s,
      actor_id: actor.id,
      notifiable_id: notifiable.id,
      notifiable_type: notifiable.class.to_s,
    )
  end
end
