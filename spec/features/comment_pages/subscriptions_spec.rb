require 'rails_helper'

describe 'comment subscriptions', js: true do
  before do
    login_to_project_as_user
    @issue = create(:issue, node: current_project.issue_library)
    visit project_issue_path(current_project, @issue)
    find('[data-behavior~=subscriptions-header]')
  end

  it 'subscribes the user in the comments header after they post a comment' do
    within('[data-behavior~=subscriptions-header]') do
      expect(page).to have_link('Subscribe')
      expect(page).not_to have_css('[data-behavior~=subscribers]')
    end

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
