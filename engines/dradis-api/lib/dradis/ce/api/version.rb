require_relative 'gem_version'

module Dradis::CE::API
  # Returns the version of the currently loaded Dradis::CE::API as a
  # <tt>Gem::Version</tt>.
  def self.version
   gem_version
  end
end
