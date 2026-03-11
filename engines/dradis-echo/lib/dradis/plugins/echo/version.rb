require_relative 'gem_version'

module Dradis
  module Plugins
    module Echo
      # Returns the version of the currently loaded Echo as a
      # <tt>Gem::Version</tt>.
      def self.version
        gem_version
      end
    end
  end
end
