require 'rails_helper'

describe 'Issues Summary widget', js: true do
  before do
    login_as_user
    @project = create(:project)
    @project.assign_owner(@logged_in_as)
  end

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

    it 'labels the chart with a legend item for each group' do
      visit project_path(current_project)

      expect(page).to have_css('[data-behavior~=issue-chart-legend-item]', count: 2)
      expect(page).to have_css('[data-behavior~=issue-chart-legend-item]', text: issue.tags.first.display_name)
      expect(page).to have_css('[data-behavior~=issue-chart-legend-item]', text: 'Unassigned')
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

  context 'with another grouping' do
    let(:issue) { create(:issue, node: current_project.issue_library) }
    let(:group_class) { Projects::Dashboard::Issues::Group }
    let(:groups) do
      [
        group_class.new(key: 'value', name: 'Unassigned', color: '#112233', issues: [issue]),
        group_class.new(key: 'unassigned', name: 'Unassigned', issues: [], unassigned: true)
      ]
    end
    let(:risk_group) { '[data-issues-summary-target="group"][data-group-color="#112233"]' }
    let(:strategy) { double(key: 'list:Risk', label: 'Risk', groups: groups) }

    before do
      issue
      allow(Projects::Dashboard::Issues::Grouping).to receive(:available).and_wrap_original do |original, project|
        original.call(project) + [strategy]
      end
    end

    def choose_grouping(label)
      within('[data-behavior~=combobox-container]') do
        find('[data-behavior~=combobox]').click
        find('[data-behavior~=combobox-option]', text: label, exact_text: true).click
      end
    end

    it 'switches both views, remembers the selection and separates identical chart labels' do
      visit project_path(current_project)
      expect(page).to have_css('[data-issues-summary-target="group"]', text: 'Unassigned')

      choose_grouping('Risk')

      expect(page).to have_css(risk_group, text: 'Unassigned')
      expect(page).to have_css('[data-issues-summary-target="group"]', count: 1)
      expect(page).to have_css('[data-behavior~=issue-chart-bar]', count: 2, visible: :all)
      positions = page.all('[data-behavior~=issue-chart-bar]', visible: :all).map { |bar| bar['x'] }
      expect(positions.uniq.size).to eq 2
      expect(page).to have_css('[data-behavior~=issue-chart-legend-item]', text: 'Unassigned', count: 2)

      visit project_path(current_project)
      expect(page).to have_css('[data-behavior~=combobox]', text: 'Risk')
      expect(page).to have_css(risk_group)

      choose_grouping('Tags')
      expect(page).to have_css('[data-issues-summary-target="group"]', text: 'Unassigned')
      expect(page).not_to have_css(risk_group)
    end

    it 'falls back when the saved grouping was removed' do
      visit project_path(current_project)
      choose_grouping('Risk')
      expect(page).to have_css(risk_group)
      allow(Projects::Dashboard::Issues::Grouping).to receive(:available).and_call_original

      visit project_path(current_project)

      expect(page).to have_css('[data-issues-summary-target="group"]', text: 'Unassigned')
      expect(page).not_to have_css('[data-behavior~=combobox]')
    end

    it 'loads and changes grouping when browser storage is unavailable' do
      visit project_path(current_project)
      expect(page).to have_css('[data-behavior~=combobox]')
      page.execute_script(<<~JS)
        Storage.prototype.getItem = Storage.prototype.setItem = () => { throw new Error('Storage unavailable'); };
        const frame = document.querySelector('[data-controller="issues-summary"]');
        frame.innerHTML = '';
        frame.removeAttribute('src');
        frame.removeAttribute('data-controller');
      JS
      page.execute_script(<<~JS)
        document.querySelector('[data-issues-summary-url-value]').setAttribute('data-controller', 'issues-summary');
      JS
      expect(page).to have_css('[data-behavior~=issue-chart-bar]')

      choose_grouping('Risk')

      expect(page).to have_css(risk_group)
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
