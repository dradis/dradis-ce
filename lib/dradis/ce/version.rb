module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 5
      MINOR = 5
      TINY = 1
      PRE = nil

      STRING = [[MAJOR, MINOR, TINY].join('.'), PRE].compact.join('-')
    end
  end
end
