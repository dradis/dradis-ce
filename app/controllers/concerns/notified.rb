module Notified
  protected

  def broadcast_notifications(action:, actor:, notifiable:, recipient_ids: [])
    NotificationsBroadcastJob.perform_later(
      action: action.to_s,
      actor_id: actor.id,
      notifiable_id: notifiable.id,
      notifiable_type: notifiable.class.to_s,
      recipient_ids: recipient_ids
    )
  end
end
