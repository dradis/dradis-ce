require 'rails_helper'

describe 'Issues Summary widget', js: true do
  before { login_to_project_as_user }

  context 'with issues' do
    let(:issue) { create(:issue, node: current_project.issue_library) }

    before do
      tag = create(:tag, project: current_project)
      issue.tags << tag
    end

    it 'initializes the chart once across repeated lifecycle events' do
      visit project_path(current_project)

      expect(page).to have_css('[data-behavior="issue-chart"] svg')
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

  context 'with several groupings' do
    let(:other_grouping) do
      Class.new(IssuesSummary::Grouping) do
        def key = 'other'
        def label = 'Other'
        def values = [OpenStruct.new(display_name: 'Mine', color: '#112233')]
        def matches?(_value, _issue) = true
      end
    end

    before do
      allow(IssuesSummary::Grouping).to receive(:available).and_wrap_original do |original, project|
        original.call(project) + [other_grouping.new(project)]
      end

      create(:issue, node: current_project.issue_library)
    end

    it 'reloads the summary when another grouping is picked' do
      visit project_path(current_project)

      expect(page).to have_css('.card-header', text: 'Unassigned')

      find('turbo-frame#issues-summary [data-behavior~="combobox"]').click
      find('turbo-frame#issues-summary [data-behavior~="combobox-option"]', text: 'Other').click

      expect(page).to have_css('.card-header', text: 'Mine')
      expect(page).to have_no_css('.card-header', text: 'Unassigned')
    end

    it 'restores the last picked grouping on the next visit' do
      visit project_path(current_project)

      find('turbo-frame#issues-summary [data-behavior~="combobox"]').click
      find('turbo-frame#issues-summary [data-behavior~="combobox-option"]', text: 'Other').click

      expect(page).to have_css('.card-header', text: 'Mine')

      visit project_path(current_project)

      expect(page).to have_css('.card-header', text: 'Mine')
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
