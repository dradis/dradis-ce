require_relative '../../../../../lib/dradis/ce/version'

module Dradis
  module Sandbox
    # Returns the version of the currently loaded Dradis::Sandbox as a
    # <tt>Gem::Version</tt>.
    def self.gem_version
      Gem::Version.new Dradis::CE::VERSION::STRING
    end
  end
end
