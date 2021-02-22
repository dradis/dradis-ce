module Dradis
  module CE
    def self.version
      File.read(File.expand_path("../../DRADIS_VERSION", __dir__)).strip
    end
  end
end

require 'html/no_inline_code_textile_formatter'

require 'html/pipeline/dradis_code_highlight_filter'
require 'html/pipeline/dradis_fieldable_filter'
require 'html/pipeline/dradis_mentions_filter'
require 'html/pipeline/dradis_textile_filter'
