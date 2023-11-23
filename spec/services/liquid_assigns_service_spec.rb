require 'rails_helper'

RSpec.describe LiquidAssignsService do
  let!(:project) { create(:project) }

  let(:liquid_assigns) { described_class.new(project).assigns }

  it 'builds a hash of liquid assigns' do
    expect(liquid_assigns['project'].name).to eq(project.name)
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
