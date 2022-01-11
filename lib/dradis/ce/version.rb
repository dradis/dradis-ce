module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 4
      MINOR = 1
      TINY  = 2
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
