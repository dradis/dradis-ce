require 'rails_helper'

RSpec.describe StaticPagesHelper do
  let(:project)  { Project.new }
  let(:issuelib) { project.issue_library }

  describe '#chart_styles' do
    let(:issue) { create(:issue, node: issuelib) }

    context 'when the issue has no evidence' do
      it 'returns full-width NO_DATA_COLOR style' do
        expect(helper.chart_styles(issue, 50)).to eq(
          "width: 100%; background-color: #{described_class::NO_DATA_COLOR};"
        )
      end
    end

    context 'when the issue has evidence' do
      let(:node) { create(:node) }

      before { create(:evidence, node: node, issue: issue) }

      it 'uses NO_TAG_COLOR when the issue has no tag' do
        expect(helper.chart_styles(issue.reload, 60)).to eq(
          "width: 60%; background-color: #{described_class::NO_TAG_COLOR};"
        )
      end

      context 'and the issue has a tag' do
        before { issue.tags << create(:tag, name: '!ff0000_red') }

        it 'uses the tag color and the given percent' do
          expect(helper.chart_styles(issue.reload, 75)).to eq(
            'width: 75%; background-color: #ff0000;'
          )
        end
      end
    end
  end

  describe '#issues_grouped_by_tag' do
    let(:tag_a)    { create(:tag, name: '!aaaaaa_alpha', position: 1) }
    let(:tag_b)    { create(:tag, name: '!bbbbbb_beta',  position: 2) }
    let(:issue_a)  { create(:issue, node: issuelib) }
    let(:issue_b)  { create(:issue, node: issuelib) }
    let(:untagged) { create(:issue, node: issuelib) }

    before do
      issue_a.tags << tag_a
      issue_b.tags << tag_b
    end

    it 'groups issues by their first tag' do
      issues = Issue.where(id: [issue_a, issue_b, untagged].map(&:id))
      result = helper.issues_grouped_by_tag(issues)
      expect(result[tag_a]).to contain_exactly(issue_a)
      expect(result[tag_b]).to contain_exactly(issue_b)
      expect(result[nil]).to contain_exactly(untagged)
    end

    it 'sorts groups by tag position with untagged issues last' do
      issues = Issue.where(id: [untagged, issue_b, issue_a].map(&:id))
      result = helper.issues_grouped_by_tag(issues)
      expect(result.keys).to eq([tag_a, tag_b, nil])
    end
  end

  describe '#top_issues_by_evidence_count' do
    let(:node) { create(:node) }

    it 'orders issues by evidence count descending' do
      issue_one   = create(:issue, node: issuelib)
      issue_two   = create(:issue, node: issuelib)
      issue_three = create(:issue, node: issuelib)

      1.times { create(:evidence, node: node, issue: issue_one) }
      2.times { create(:evidence, node: node, issue: issue_two) }
      3.times { create(:evidence, node: node, issue: issue_three) }

      result = helper.top_issues_by_evidence_count(project, limit: 3)
      expect(result.map(&:id)).to eq([issue_three.id, issue_two.id, issue_one.id])
    end

    it 'includes issues with zero evidence' do
      issue_with_evidence = create(:issue, node: issuelib)
      issue_no_evidence   = create(:issue, node: issuelib)
      create(:evidence, node: node, issue: issue_with_evidence)

      result = helper.top_issues_by_evidence_count(project, limit: 2)
      expect(result).to include(issue_no_evidence)
    end

    it 'respects the limit' do
      4.times { create(:issue, node: issuelib) }
      expect(helper.top_issues_by_evidence_count(project, limit: 3).to_a.size).to eq(3)
    end
  end

  describe '#top_nodes_by_issue_count' do
    it 'orders nodes by distinct issue count descending' do
      node_one   = create(:node)
      node_three = create(:node)

      create(:evidence, node: node_one, issue: create(:issue, node: issuelib))
      3.times { create(:evidence, node: node_three, issue: create(:issue, node: issuelib)) }

      result = helper.top_nodes_by_issue_count(project)
      expect(result.first.id).to eq(node_three.id)
    end

    it 'excludes system nodes such as the issue library' do
      user_node = create(:node)
      issue = create(:issue, node: issuelib)
      create(:evidence, node: user_node, issue: issue)

      result = helper.top_nodes_by_issue_count(project)
      expect(result.map(&:id)).not_to include(issuelib.id)
      expect(result.map(&:id)).to include(user_node.id)
    end

    it 'respects the limit' do
      4.times { create(:evidence, node: create(:node), issue: create(:issue, node: issuelib)) }
      expect(helper.top_nodes_by_issue_count(project, limit: 3).to_a.size).to eq(3)
    end
  end
end
