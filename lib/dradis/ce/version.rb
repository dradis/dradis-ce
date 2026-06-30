module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 5
      MINOR = 1
      TINY = 0
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
