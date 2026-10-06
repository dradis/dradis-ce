require 'rails_helper'

describe 'Tab memory', js: true do
  before { login_to_project_as_user }

  context 'on Issues' do
    let(:record) { create(:issue, node: current_project.issue_library) }
    let(:other_record) { create(:issue, node: current_project.issue_library) }
    let(:record_path) { project_issue_path(current_project, record) }
    let(:other_record_path) { project_issue_path(current_project, other_record) }
    let(:default_tab) { '#info-tab' }
    let(:other_tab) { '#evidence-tab' }

    it_behaves_like 'remembered tabs'

    it 'remembers addon tabs without additional markup' do
      visit record_path
      find('[data-bs-toggle="tab"][href="#echo-tab"]').click
      expect(page).to have_css('#echo-tab.active')

      visit record_path
      expect(page).to have_css('#echo-tab.active')
    end

    it 'keeps QA and normal Issue preferences separate' do
      record.update!(state: :ready_for_review)
      visit record_path
      find('[data-bs-toggle="tab"][href="#evidence-tab"]').click
      expect(page).to have_css('#evidence-tab.active')

      visit project_qa_issue_path(current_project, record)
      expect(page).to have_css('#info-tab.active')
    end
  end

  context 'on Nodes' do
    let(:record) { create(:node, project: current_project) }
    let(:other_record) { create(:node, project: current_project) }
    let(:record_path) { project_node_path(current_project, record) }
    let(:other_record_path) { project_node_path(current_project, other_record) }
    let(:default_tab) { '#properties-tab' }
    let(:other_tab) { '#notes-tab' }

    it_behaves_like 'remembered tabs'
  end
end
