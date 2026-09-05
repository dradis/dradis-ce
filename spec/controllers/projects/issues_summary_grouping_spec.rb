require 'rails_helper'

describe Projects::IssuesSummaryGrouping do
  describe '#build_tags_grouping' do
    it 'groups tagged and unassigned issues and builds the chart attributes' do
      host = Class.new { include Projects::IssuesSummaryGrouping }.new
      tag = create(:tag, name: '!dc3545_critical')
      tagged_issue = create(:issue)
      tagged_issue.tags << tag
      unassigned_issue = create(:issue)

      host.instance_variable_set(:@tags, [tag])
      host.instance_variable_set(:@issues, [tagged_issue, unassigned_issue])

      host.send(:build_tags_grouping)

      expect(host.instance_variable_get(:@issues_by_tag)).to eq(
        tag.name => [tagged_issue], unassigned: [unassigned_issue]
      )
      expect(host.instance_variable_get(:@count_by_tag)).to eq(
        tag.name => 1, unassigned: 1
      )
      expect(host.instance_variable_get(:@tag_names)).to eq(
        tag.name => [tag.display_name, tag.color]
      )
    end
  end

  describe '#list_fields' do
    it 'returns no list fields' do
      host = Class.new { include Projects::IssuesSummaryGrouping }.new

      expect(host.send(:list_fields)).to eq([])
    end
  end
end
