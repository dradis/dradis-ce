module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 1
      TINY  = 0
      PRE = nil

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')
    end

    def self.version
      VERSION::STRING
    end
  end
end
