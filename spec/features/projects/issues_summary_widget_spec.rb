require 'rails_helper'

describe 'Issues Summary widget', js: true do
  before do
    login_to_project_as_user

    tag = create(:tag)
    issue = create(:issue, node: current_project.issue_library)
    issue.tags << tag
  end

  it 'initializes the chart once across repeated lifecycle events' do
    visit project_path(current_project)

    expect(page).to have_css('[data-behavior="issue-chart"] svg')
  end

  it 'initializes the chart once when called repeatedly' do
    visit project_path(current_project)

    expect(page).to have_css('[data-behavior="issue-chart"] svg')

    page.execute_script('initIssuesChart(); initIssuesChart();')

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
end
