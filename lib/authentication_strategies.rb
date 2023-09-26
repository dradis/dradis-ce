class AuthenticationStrategies
  @@strategies = [:shared_password]

  class << self
    attr_accessor :strategies
  end

  ActiveSupport.run_load_hooks(:authentication_strategies)
end
