require 'rails_helper'

describe Projects::Dashboard::Issues::Grouping do
  let(:project) { create(:project) }
  let(:grouping) { described_class.available(project).first }
  let(:node) { project.issue_library }
  let!(:critical) { create(:tag, name: '!9467bd_critical', project: project) }
  let!(:low) { create(:tag, name: '!6baed6_low', project: project) }

  describe '#groups' do
    it 'lists each issue under every tag it has, then the untagged ones as unassigned' do
      tagged = create(:issue, node: node).tap { |issue| issue.tags << critical }
      multi_tagged = create(:issue, node: node).tap { |issue| issue.tags << critical << low }
      untagged = create(:issue, node: node)

      groups = grouping.groups(project.issues.includes(:tags))

      expect(groups.map(&:name)).to eq [critical.display_name, low.display_name, 'Unassigned']
      expect(groups.map(&:issues).map(&:to_set)).to eq [
        Set[tagged, multi_tagged], Set[multi_tagged], Set[untagged]
      ]
    end

    it 'puts issues that only have tags outside the project in the unassigned group' do
      outsider = create(:issue, node: node)
      outsider.tags << create(:tag, name: '!000000_other')
      grouping = described_class.new(key: 'tags', label: 'Tags', values: [critical])

      expect(grouping.groups([outsider]).last.issues).to eq [outsider]
    end
  end
end
