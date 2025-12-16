class ActivityService
  def self.configure(&block)
    raise ArgumentError, 'must provide a block' unless block_given?
    block.arity.zero? ? instance_eval(&block) : yield(self)
  end

  def self.subscribe_namespace(namespace)
    regex = Regexp.new("^#{Regexp.escape(namespace)}\.*")

    ActiveSupport::Notifications.subscribe(regex) do |event|
      payload = event.payload

      ActivityTrackingJob.perform_later(
        action: payload[:action].to_s,
        project_id: payload[:project] ? payload[:project][:id] : nil,
        trackable_id: payload[:id],
        trackable_type: payload[:class],
        user_id: payload[:user][:id]
      )
    end
  end
end
