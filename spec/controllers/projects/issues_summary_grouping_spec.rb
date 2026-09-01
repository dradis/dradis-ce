require 'rails_helper'

describe Projects::IssuesSummaryGrouping do
  describe '#build_tags_grouping' do
    it 'groups tagged and unassigned issues and builds chart data' do
      host = Class.new do
        include Projects::IssuesSummaryGrouping
      end.new
      tag = Struct.new(:name, :display_name, :color).new('critical', 'Critical', '#dc3545')
      tagged_issue = Struct.new(:tags).new([tag])
      unassigned_issue = Struct.new(:tags).new([])

      host.instance_variable_set(:@issues, [tagged_issue, unassigned_issue])
      host.instance_variable_set(:@tags, [tag])

      host.send(:build_tags_grouping)

      expect(host.instance_variable_get(:@issues_by_tag)).to eq({
        'critical' => [tagged_issue],
        unassigned: [unassigned_issue]
      })
      expect(host.instance_variable_get(:@count_by_tag)).to eq({ 'critical' => 1, unassigned: 1 })
      expect(host.instance_variable_get(:@chart_data)).to eq({
        dimension: 'tags',
        issues_count: '{"critical":1,"unassigned":1}',
        tags: '{"critical":["Critical","#dc3545"]}'
      })
    end
  end

  describe '#list_fields' do
    it 'returns an empty array' do
      host = Class.new do
        include Projects::IssuesSummaryGrouping
      end.new

      expect(host.send(:list_fields)).to eq([])
    end
  end
end
