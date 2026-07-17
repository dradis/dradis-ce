require 'rails_helper'

describe 'Issues Summary', js: true do
  subject { page }

  before do
    login_to_project_as_user

    tag = create(:tag)
    issue = create(:issue, node: current_project.issue_library)
    issue.tags << tag
  end

  describe 'when in the projects show view' do
    it 'lazy-loads and renders the issues chart' do
      visit project_path(current_project)

      expect(page).to have_selector('#issue-chart svg')
    end
  end
end
