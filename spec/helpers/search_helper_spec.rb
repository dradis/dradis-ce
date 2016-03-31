require "spec_helper"

describe SearchHelper do
  describe ".search_path" do
    %w[all nodes notes issues evidences].each do |scope|
      it "formats correct #{scope} path" do
        expect(helper.search_filter_path(options(term: "test", scope: scope))).
          to eq "/search?q=test&scope=#{scope}"
      end
    end

    it "returns empty search path when no options provided" do
      expect(helper.search_filter_path).to eq "/search"
    end
  end
end

def options(term:, scope:)
  Hash.new.tap do
    params[:q] = term
    params[:scope] = scope
  end
end
