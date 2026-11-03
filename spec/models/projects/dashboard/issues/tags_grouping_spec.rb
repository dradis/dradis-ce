require 'rails_helper'

describe Projects::Dashboard::Issues::TagsGrouping do
  let(:project) { create(:project) }
  let(:grouping) { described_class.new(project) }
  let!(:high) { create(:tag, name: '!ff0000_high', project: project) }
  let!(:low) { create(:tag, name: '!0000ff_low', project: project) }
  let!(:empty) { create(:tag, name: '!00ff00_empty', project: project) }

  it 'preserves tag and issue order, including multiple memberships and empty buckets' do
    first = create(:issue, node: project.issue_library)
    second = create(:issue, node: project.issue_library)
    untagged = create(:issue, node: project.issue_library)
    first.tags << high << low
    second.tags << high

    groups = grouping.groups([second, first, untagged])

    expect(groups.map(&:name)).to eq ['High', 'Low', 'Empty', 'Unassigned']
    expect(groups.map(&:issues)).to eq [[second, first], [first], [], [untagged]]
    expect(groups.map(&:count)).to eq [2, 1, 0, 1]
    expect(groups.last).to be_unassigned
  end

  it 'puts issues with no matching project tag in the fallback bucket' do
    issue = create(:issue, node: project.issue_library)
    issue.tags << low
    allow(project).to receive(:tags).and_return([high])

    expect(grouping.groups([issue]).last.issues).to eq [issue]
  end

  it 'gives identically named groups distinct chart keys' do
    create(:tag, name: '!00ffff_high', project: project)
    groups = grouping.groups([])

    expect(groups.count { |group| group.name == 'High' }).to eq 2
    expect(groups.map { |group| group.chart_data[:key] }.uniq.size).to eq groups.size
  end
end
