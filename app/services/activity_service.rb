class ActivityService
  def self.configure(&block)
    raise ArgumentError, 'must provide a block' unless block_given?
    block.arity.zero? ? instance_eval(&block) : yield(self)
  end

  def self.subscribe_event(event_name)
    ActiveSupport::Notifications.subscribe(event_name) do |event|
      payload = event.payload

      ActivityTrackingJob.perform_later(
        action: payload[:action].to_s,
        project_id: payload[:project] ? payload[:project].id : nil,
        trackable_id: payload[:id],
        trackable_type: payload[:class],
        user_id: payload[:user][:id]
      )
    end
  end

  def self.subscribe_model(namespace: 'main', model_name:)
    [:create, :destroy, :update].each do |action|
      event_name = [namespace]
      event_name << model_name
      event_name << action.to_s

      ActivityService.subscribe_event event_name.join('.')
    end
  end
end
