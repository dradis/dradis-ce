module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 17
      TINY  = 1
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
