require 'rails_helper'

describe 'Issues grouping selector', js: true do
  before do
    login_to_project_as_user

    tag = create(:tag)
    issue = create(:issue, node: current_project.issue_library)
    issue.tags << tag
  end

  after do
    page.execute_script("localStorage.removeItem('project.pro.#{current_project.id}.issues_grouping')")
  end

  it 'persists the selected grouping per project and updates the frame src' do
    visit project_path(current_project)

    page.execute_script(<<~JS)
      const select = document.querySelector('.issues-grouping-select')
      select.value = 'tags'
      select.dispatchEvent(new Event('change', { bubbles: true }))
    JS

    stored = page.evaluate_script("localStorage.getItem('project.pro.#{current_project.id}.issues_grouping')")
    expect(stored).to eq('tags')
    expect(page).to have_selector('turbo-frame#issues-summary[src*="grouping=tags"]', visible: false)
  end

  it 'restores the stored grouping on the next load' do
    visit project_path(current_project)
    page.execute_script("localStorage.setItem('project.pro.#{current_project.id}.issues_grouping', 'tags')")

    visit project_path(current_project)

    expect(page).to have_selector('turbo-frame#issues-summary[src*="grouping=tags"]', visible: false)
  end
end
