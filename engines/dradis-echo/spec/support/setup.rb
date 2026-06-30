RSpec.configure do |config|
  config.before(:suite) do
    # Roslin is enabled by default; keep existing test data disabled so grammar
    # checks don't run across all views unless a test explicitly enables it.
    agent = Dradis::Plugins::Echo::Agents::Roslin
    agent.instance.update!(enabled: false) if agent.enabled?
  end
end
