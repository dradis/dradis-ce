require 'rails_helper'

describe 'Issues Summary', js: true do
  subject { page }

  let(:issue) { create(:issue, node: current_project.issue_library) }

  before do
    login_to_project_as_user

    tag = create(:tag)
    issue.tags << tag
  end

  describe 'when in the projects show view' do
    it 'lazy-loads and renders the issues chart' do
      visit project_path(current_project)

      expect(page).to have_selector('#issue-chart svg')
    end

    it 'navigates to the full issue page when an accordion link is clicked' do
      visit project_path(current_project)

      click_link issue.title

      expect(page).to have_current_path(project_issue_path(current_project, issue))
    end
  end
end
