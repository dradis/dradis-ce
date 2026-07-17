module Dradis::Plugins::Echo
  # Shared `check_turbo_config` before_action for the streaming controllers.
  # Turbo Streams only work if Action Cable can reach its backend, so the view
  # can warn the user when it can't.
  #
  # Only the Redis adapter needs a reachable external server, so we ping just
  # that one and memoize the result. Every other adapter (async in development,
  # test in specs) is always treated as healthy — no spurious "can't contact
  # Redis" alert and no per-request Redis round-trip.
  module TurboConfigCheck
    extend ActiveSupport::Concern

    private

    def check_turbo_config
      return @turbo_status if defined?(@turbo_status)

      @turbo_status = turbo_backend_reachable?
    end

    def turbo_backend_reachable?
      adapter = ActionCable.server.pubsub
      return true unless adapter.is_a?(ActionCable::SubscriptionAdapter::Redis)

      adapter.redis_connection_for_subscriptions.ping
      true
    rescue StandardError
      false
    end
  end
end
