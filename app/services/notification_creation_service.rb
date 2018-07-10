class NotificationCreationService
  def initialize(action:, actor:, notifiable:)
    @action     = action
    @actor      = actor
    @notifiable = notifiable
  end

  def create_notifications
    return unless @notifiable.respond_to?(:subscriptions_for_action)

    subscriptions = @notifiable.subscriptions_for_action(@action) || []

    ActiveRecord::Base.transaction do
      subscriptions.each do |subscription|
        Notification.create(
          action: @action,
          actor: @actor,
          notifiable: @notifiable,
          recipient: subscription.user
        )
      end
    end
  end
end
