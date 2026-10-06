require 'rails_helper'

describe IssuesSummary::TagsGrouping do
  let(:project) { current_project }
  let(:grouping) { described_class.new(project) }
  let(:node) { project.issue_library }
  let!(:critical) { create(:tag, name: '!9467bd_critical', project: project) }
  let!(:low) { create(:tag, name: '!6baed6_low', project: project) }

  describe '#key and #label' do
    it { expect(grouping.key).to eq 'tags' }
    it { expect(grouping.label).to eq 'Tags' }
  end

  describe '#groups' do
    let!(:tagged) { create(:issue, node: node).tap { |issue| issue.tags << critical } }
    let!(:multi_tagged) { create(:issue, node: node).tap { |issue| issue.tags << critical << low } }
    let!(:untagged) { create(:issue, node: node) }
    let(:groups) { grouping.groups(project.issues.includes(:tags)) }

    it 'returns one group per tag followed by the unassigned group' do
      expect(groups.map(&:name)).to eq [critical.display_name, low.display_name, 'Unassigned']
      expect(groups.map(&:unassigned?)).to eq [false, false, true]
    end

    it 'exposes the tag colors' do
      expect(groups.first(2).map(&:color)).to eq [critical.color, low.color]
    end

    it 'lists an issue in every tag it has' do
      expect(groups.first.issues).to match_array [tagged, multi_tagged]
      expect(groups.second.issues).to match_array [multi_tagged]
    end

    it 'puts issues without a tag in the unassigned group' do
      expect(groups.last.issues).to eq [untagged]
    end

    it 'counts the issues in each group' do
      expect(groups.map(&:count)).to eq [2, 1, 1]
    end

    it 'puts issues that only have tags outside the project in the unassigned group' do
      outsider = create(:issue, node: node)
      outsider.tags << create(:tag, name: '!000000_other')
      allow(grouping).to receive(:values).and_return([critical])

      expect(grouping.groups([outsider]).last.issues).to eq [outsider]
    end
  end
end
