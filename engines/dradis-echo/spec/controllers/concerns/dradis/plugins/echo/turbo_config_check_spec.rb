require 'rails_helper'

describe Dradis::Plugins::Echo::TurboConfigCheck do
  subject(:controller) do
    Class.new { include Dradis::Plugins::Echo::TurboConfigCheck }.new
  end

  describe '#check_turbo_config' do
    it 'reports healthy without pinging when the adapter is not Redis' do
      # A plain double doesn't respond_to :redis_connection_for_subscriptions,
      # so the duck-typed guard returns healthy without a ping. (Stubbing the
      # method here would make respond_to? true and defeat the check — an
      # unexpected call would instead raise, still failing the example.)
      adapter = double('non-redis adapter')
      allow(ActionCable.server).to receive(:pubsub).and_return(adapter)

      expect(controller.send(:check_turbo_config)).to be(true)
    end

    it 'pings and reports healthy for a reachable Redis adapter' do
      redis = double('redis', ping: 'PONG')
      adapter = ActionCable::SubscriptionAdapter::Redis.allocate
      allow(adapter).to receive(:redis_connection_for_subscriptions).and_return(redis)
      allow(ActionCable.server).to receive(:pubsub).and_return(adapter)

      expect(controller.send(:check_turbo_config)).to be(true)
    end

    it 'reports unhealthy when the Redis ping fails' do
      adapter = ActionCable::SubscriptionAdapter::Redis.allocate
      allow(adapter).to receive(:redis_connection_for_subscriptions).and_raise(StandardError)
      allow(ActionCable.server).to receive(:pubsub).and_return(adapter)

      expect(controller.send(:check_turbo_config)).to be(false)
    end
  end
end
