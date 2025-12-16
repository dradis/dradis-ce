module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 4
      MINOR = 19
      TINY  = 0
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
