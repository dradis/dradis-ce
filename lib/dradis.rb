module Dradis
  class << self
    SANDBOX_FILE_PATH = 'tmp/sandbox.txt'

    def sandbox?
      return @sandbox if defined?(@sandbox)
      @sandbox = !!(((ENV['SANDBOX'] || File.exist?(File.expand_path(SANDBOX_FILE_PATH, __dir__))) && ENV['SANDBOX'] != 'false'))
    end

    def configure_bundle
      if sandbox?
        ENV['BUNDLE_GEMFILE'] = 'Gemfile.sandbox'
      end
    end
  end
end
