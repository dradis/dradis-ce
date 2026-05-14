module Dradis::Plugins::Echo
  module Agent
    def form_key
      name.demodulize.underscore
    end
  end
end
