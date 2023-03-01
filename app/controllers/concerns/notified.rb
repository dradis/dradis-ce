module Notified
  protected

  def broadcast_notifications(action:, notifiable:, user:, recipient_ids: [])
    NotificationsBroadcastingJob.perform_later(
      action: action.to_s,
      notifiable_id: notifiable.id,
      notifiable_type: notifiable.class.to_s,
      recipient_ids: recipient_ids,
      user_id: user.id
    )
  end
end
