RSpec.configure do |config|
  config.before(:suite) do
    # The migration creates Roslin enabled; disable it so grammar checks don't
    # run across all views during specs unless a test explicitly enables it.
    agent = Dradis::Plugins::Echo::Agents::Roslin
    agent.instance.update!(enabled: false) if agent.enabled?
  end
end
