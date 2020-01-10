require_relative 'ce/version'

module Dradis
  module CE
    def self.version
      VERSION::STRING
    end
  end
end

require 'html/pipeline/dradis_code_highlight_filter'
require 'html/pipeline/dradis_comment_filter'
require 'html/pipeline/dradis_fieldable_filter'
require 'html/pipeline/dradis_mentions_filter'
require 'html/pipeline/dradis_textile_filter'
