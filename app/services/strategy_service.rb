class StrategyService
  @@strategies = [:shared_password]

  class << self
    attr_accessor :strategies
  end

  ActiveSupport.run_load_hooks(:strategy_service)
end
