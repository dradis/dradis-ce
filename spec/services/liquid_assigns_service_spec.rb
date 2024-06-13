require 'rails_helper'

RSpec.describe LiquidAssignsService do
  let!(:project) { create(:project) }

  before do
    node = create(:node, project: project)
    issue = create(:issue, node: project.issue_library)
    create(:evidence, issue: issue, node: node)
    create(:note, node: node)
    create(:tag)
  end

  describe '#project_assigns' do
    context 'with the :text argument' do
      LiquidAssignsService::AVAILABLE_PROJECT_ASSIGNS.each do |assign|
        it "adds #{assign} to the project_assigns if present in the text" do
          text = "#[Description]#\n {% for #{assign.singularize} in #{assign} %}{% endfor %}\n"
          liquid_assigns = described_class.new(project: project, text: text).assigns

          expect(liquid_assigns.keys).to include(assign)
        end
      end
    end

    context 'without the :text argument' do
      let(:liquid_assigns) { described_class.new(project: project).assigns }

      it 'builds a hash of liquid assigns' do
        expect(liquid_assigns['project'].name).to eq(project.name)
        expect(liquid_assigns['issues'].map(&:title)).to eq(project.issues.map(&:title))
        expect(liquid_assigns['evidences'].map(&:title)).to eq(project.evidence.map(&:title))
        expect(liquid_assigns['nodes'].map(&:label)).to eq(project.nodes.user_nodes.map(&:label))
        expect(liquid_assigns['notes'].map(&:title)).to eq(project.notes.map(&:title))
        expect(liquid_assigns['tags'].map(&:display_name)).to eq(project.tags.map(&:display_name))
      end
    end
  end

  context 'with pro records', skip: !defined?(Dradis::Pro)  do
    let(:liquid_assigns) { described_class.new(project: project).assigns }

    let!(:project) { create(:project, :with_team) }

    before do
      report_content = project.content_library
      report_content.properties = { 'dradis.project' => project.name }
      report_content.save

      create(:content_block, project: project)
    end

    it 'builds a hash with Dradis::Pro assigns' do
      expect(liquid_assigns['document_properties'].available_properties).to eq({ 'dradis.project' => project.name })
      expect(liquid_assigns['team'].name).to eq(project.team.name)
      expect(liquid_assigns['content_blocks'].map(&:content)).to eq(project.content_blocks.map(&:content))
    end
  end
end
