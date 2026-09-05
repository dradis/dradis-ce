require 'rails_helper'

describe 'Issues Summary widget', js: true do
  before { login_to_project_as_user }

  context 'with issues' do
    let(:issue) { create(:issue, node: current_project.issue_library) }

    before do
      tag = create(:tag)
      issue.tags << tag
    end

    it 'initializes the chart once across repeated lifecycle events' do
      visit project_path(current_project)

      expect(page).to have_css('[data-behavior="issue-chart"] svg')
    end

    it 'renders a legend item for each tag and one for unassigned' do
      visit project_path(current_project)

      expect(page).to have_css('.issue-chart-legend .legend-item', count: 2)
      expect(page).to have_css('.issue-chart-legend .legend-item.untagged', text: 'N/A')
    end

    it 'initializes the chart once when called repeatedly' do
      visit project_path(current_project)

      expect(page).to have_css('[data-behavior="issue-chart"] svg')

      page.execute_script(<<~JS)
        document.dispatchEvent(new Event('turbo:load'));
        document.dispatchEvent(new Event('turbo:frame-load'));
      JS

      expect(page).to have_css('[data-behavior="issue-chart"] svg', count: 1)
    end

    it 'updates the accordion caret after the frame loads' do
      visit project_path(current_project)

      expect(page).to have_css('[data-behavior="caret-icon"].fa-caret-up')

      page.execute_script(<<~JS)
        const frame = document.querySelector('turbo-frame#issues-summary');
        frame.innerHTML = '';
        frame.reload();
      JS

      expect(page).to have_css('[data-behavior="caret-icon"].fa-caret-up')

      first('[data-behavior="card-header"]').click

      expect(page).to have_css('[data-behavior="caret-icon"].fa-caret-down')
    end

    it 'navigates to the full issue page when an accordion link is clicked' do
      visit project_path(current_project)

      click_link issue.title

      expect(page).to have_current_path(project_issue_path(current_project, issue))
    end
  end

  context 'without issues' do
    it 'navigates to the issues page from the empty state' do
      visit project_path(current_project)

      click_on 'Go To Issues'

      expect(page).to have_current_path(project_issues_path(current_project))
    end
  end
end
