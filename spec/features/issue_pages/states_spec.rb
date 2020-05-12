require 'rails_helper'

describe 'issue pages' do
  describe 'states', js: true do
    before do
      login_to_project_as_user

      # create 2 issues
      @issue1 = create(:issue, node: current_project.issue_library, state: :draft)
      @issue2 = create(:issue, node: current_project.issue_library, state: :draft)

      visit project_issues_path(current_project)

      # Enable 'State' as a column for the issues table
      within('.btn-toolbar') do
        find('.btn-group.dropdown').click
      end

      within('.js-table-columns') do
        find('[data-column="state"]').click
      end

      # click > 1 issue checkboxes
      all('input.js-multicheck').each(&:click)

      find('#state-selected').click
    end

    it 'updates the state of the issues' do
      find('[data-state="published"]').click

      find('td', text: 'Published', match: :first)

      expect(@issue1.reload.state).to eq('published')
      expect(@issue2.reload.state).to eq('published')
    end
  end
end
