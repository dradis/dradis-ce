module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 16
      TINY  = 0
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
