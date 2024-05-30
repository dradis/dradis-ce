require 'rails_helper'

RSpec.describe LiquidAssignsService do
  let!(:project) { create(:project) }

  let(:liquid_assigns) { described_class.new(project).assigns }

  before do
    node = create(:node, project: project)
    issue = create(:issue, node: project.issue_library)
    create(:evidence, issue: issue, node: node)
    create(:note, node: node)
    create(:tag)
  end

  it 'builds a hash of liquid assigns' do
    expect(liquid_assigns['project'].name).to eq(project.name)
    expect(liquid_assigns['issues'].map(&:title)).to eq(project.issues.map(&:title))
    expect(liquid_assigns['evidence'].map(&:title)).to eq(project.evidence.map(&:title))
    expect(liquid_assigns['nodes'].map(&:label)).to eq(project.nodes.user_nodes.map(&:label))
    expect(liquid_assigns['notes'].map(&:title)).to eq(project.notes.map(&:title))
    expect(liquid_assigns['tags'].map(&:display_name)).to eq(project.tags.map(&:display_name))
  end

  context 'with pro records', skip: !defined?(Dradis::Pro)  do
    let!(:project) { create(:project, :with_team) }

    before do
      report_content = project.content_library
      report_content.properties = { 'dradis.project' => project.name }
      report_content.save
    end

    it 'builds a hash with Dradis::Pro assigns' do
      expect(liquid_assigns['document_properties'].available_properties).to eq({ 'dradis.project' => project.name })
      expect(liquid_assigns['team'].name).to eq(project.team.name)
    end
  end
end
