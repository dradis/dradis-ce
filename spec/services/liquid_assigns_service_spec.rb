require 'rails_helper'

RSpec.describe LiquidAssignsService do
  let!(:project) { create(:project) }
  let!(:nodes) { create_list(:node, 5, project: project) }
  let!(:issues) { create_list(:issue, 5, node: project.issue_library) }
  let!(:evidence) { create_list(:evidence, 5, node: nodes.first, issue: issues.first) }
  let!(:tags) { create_list(:tag, 5, project: project) }

  let(:liquid_assigns) { described_class.new(project).assigns }

  it 'builds a hash of liquid assigns' do

    expect(liquid_assigns['project'].name).to eq(project.name)
    expect(liquid_assigns['nodes'].map(&:label)).to match_array(nodes.pluck(:label))
    expect(liquid_assigns['issues'].map(&:title)).to match_array(issues.map(&:title))
    expect(liquid_assigns['evidences'].map(&:title)).to match_array(evidence.map(&:title))
    expect(liquid_assigns['tags'].map(&:name)).to match_array(tags.pluck(:name))
  end
end
