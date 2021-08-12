require_relative '../../../../../../lib/dradis/ce/version'

module Dradis
  module CE
    module API
      # Returns the version of the currently loaded Dradis::CE::API as a
      # <tt>Gem::Version</tt>.
      def self.gem_version
        Gem::Version.new Dradis::CE::VERSION::STRING
      end
    end
  end
end
