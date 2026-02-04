require_relative 'gem_version'

module Dradis::Sandbox
  # Returns the version of the currently loaded Dradis::Sandbox as a
  # <tt>Gem::Version</tt>.
  def self.version
    gem_version
  end
end
