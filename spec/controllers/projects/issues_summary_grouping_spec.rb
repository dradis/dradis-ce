require 'rails_helper'

describe Projects::IssuesSummaryGrouping do
  describe '#build_tags_grouping' do
    it 'provides the project issues summary tag grouping' do
      host = Class.new do
        include Projects::IssuesSummaryGrouping
      end.new

      expect(host.send(:respond_to?, :build_tags_grouping, true)).to be(true)
    end
  end
end
