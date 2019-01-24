require_relative 'ce/version'

module Dradis
  module CE
    def self.version
      VERSION::STRING
    end
  end
end

require 'html/pipeline/dradis_fieldable_filter'
require 'html/pipeline/dradis_escape_html_filter'
require 'html/pipeline/dradis_textile_filter'
