module Dradis
  module CE #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 6
      TINY  = 0
      PRE = 'rc1'

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')
    end
  end
end
