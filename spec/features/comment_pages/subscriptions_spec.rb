require 'rails_helper'

describe 'comment subscriptions', js: true do
  before do
    login_to_project_as_user
    @issue = create(:issue, node: current_project.issue_library)
    visit project_issue_path(current_project, @issue)
    find('[data-behavior~=subscriptions-header]')
  end

  it 'updates the comments header in place when subscribing, unsubscribing and commenting' do
    page.execute_script('window.notReloaded = true')

    within('[data-behavior~=subscriptions-header]') do
      click_link 'Subscribe'
      expect(page).to have_link('Unsubscribe')
      expect(page).to have_css('[data-behavior~=subscribers-toggle] .gravatar', count: 1)

      click_link 'Unsubscribe'
      expect(page).to have_link('Subscribe')
      expect(page).not_to have_css('[data-behavior~=subscribers]')
    end

    expect(page.evaluate_script('window.notReloaded')).to be(true)

    within('[data-behavior~=add-comment]') do
      find('textarea').set('A new comment')
      click_button 'Add comment'
    end

    within('[data-behavior~=subscriptions-header]') do
      expect(page).to have_link('Unsubscribe')
      expect(page).to have_css('[data-behavior~=subscribers-toggle] .gravatar', count: 1)
    end
  end
end
