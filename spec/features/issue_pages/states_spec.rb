require 'rails_helper'

describe 'issue pages' do
  describe 'states', js: true do
    before do
      login_to_project_as_user

      # create 2 issues
      @issue1 = create(:issue, node: current_project.issue_library, state: 0)
      @issue2 = create(:issue, node: current_project.issue_library, state: 0)

      visit project_issues_path(current_project)

      # click > 1 issue checkboxes
      page.all('input.js-multicheck').each(&:click)

      find('#state-selected').click
    end

    it 'updates the state of the issues' do
      find('[data-state="published"]').click

      # Replace with loading check once implemented
      # wait for ajax
      sleep(1)

      expect(@issue1.reload.state).to eq('published')
      expect(@issue2.reload.state).to eq('published')
    end
  end
end
