require 'rails_helper'

describe 'issue-evidence page' do
  before do
    login_to_project_as_user

    issue = create(:issue, node: current_project.issue_library, evidence: build_list(:evidence, 2, node: current_project.issue_library))

    visit project_issue_path(current_project, issue)

    click_link('Evidence')
  end

  describe 'delete multiple evidence', js: true do
    it 'selects and deletes evidence from issue' do
      find('#issues-evidence-select-all').click

      find('.js-issues-evidence-delete').click

      # "Are you sure?" dialog
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content 'Evidence deleted for selected nodes.'
      expect(Evidence.count).to eq 0
    end
  end
end
