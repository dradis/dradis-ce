class AuthenticationStrategies
  @@strategies = [:shared_password]

  class << self
    attr_accessor :strategies
  end
end
