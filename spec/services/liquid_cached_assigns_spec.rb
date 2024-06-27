require 'rails_helper'

RSpec.describe LiquidCachedAssigns do
  let!(:project) { create(:project) }
  let(:liquid_assigns) { described_class.new(project: project) }

  before do
    node = create(:node, project: project)
    issue = create(:issue, node: project.issue_library)
    create(:evidence, issue: issue, node: node)
    create(:note, node: node)
    create(:tag)
  end

  context 'fetching an assign from an available collection' do
    it 'lazily loads the assigns' do
      expect(liquid_assigns.assigns.keys).to_not include(
        %w{issues evidences nodes notes tags}
      )
    end

    it 'builds a hash of liquid assigns' do
      issues = project.issues.map(&:title)

      expect(liquid_assigns['project'].name).to eq(project.name)
      expect(liquid_assigns['issues'].map(&:title)).to eq(issues)
      expect(liquid_assigns['evidences'].map(&:title)).to eq(project.evidence.map(&:title))
      expect(liquid_assigns['nodes'].map(&:label)).to eq(project.nodes.user_nodes.map(&:label))
      expect(liquid_assigns['notes'].map(&:title)).to eq(project.notes.map(&:title) - issues)
      expect(liquid_assigns['tags'].map(&:display_name)).to eq(project.tags.map(&:display_name))
    end
  end

  context 'fetching an assign from a unavailable collection' do
    it 'returns an empty array' do
      expect(liquid_assigns['fake']).to be_empty
    end
  end

  context 'with pro records', skip: !defined?(Dradis::Pro)  do
    let!(:project) { create(:project, :with_team) }

    before do
      report_content = project.content_library
      report_content.properties = { 'dradis.project' => project.name }
      report_content.save

      create(:content_block, project: project)
    end

    context 'fetching an assign from an available collection' do
      it 'lazily loads the assigns' do
        expect(liquid_assigns.assigns.keys).to_not include('content_blocks')
      end

      it 'builds a hash with Dradis::Pro assigns' do
        expect(liquid_assigns['document_properties'].available_properties).to eq({ 'dradis.project' => project.name })
        expect(liquid_assigns['team'].name).to eq(project.team.name)
        expect(liquid_assigns['content_blocks'].map(&:content)).to eq(project.content_blocks.map(&:content))
      end
    end
  end
end
