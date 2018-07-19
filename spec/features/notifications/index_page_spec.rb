require 'rails_helper'

RSpec.describe 'notifications index page' do
  before do
    login_to_project_as_user
  end

  let(:me) { @logged_in_as }
  let(:u1) { create(:user) }
  let(:u2) { create(:user) }

  example 'when I have no notifications' do
    # other users have notifications but you don't:
    create(:notification, recipient: u1, notifiable: create(:comment))
    create(:notification, recipient: u2, notifiable: create(:comment))

    visit project_notifications_path(@project)

    expect(page).not_to have_selector '.notification'
    expect(page).to have_content 'You have no notifications yet'
  end

  example 'when I have notifications' do
    # my notifications: 1 read, 1 unread
    create(:notification, recipient: me, notifiable: create(:comment))
    create(:notification, recipient: me, notifiable: create(:comment), read_at: Time.now)

    # other people's notifications:
    create(:notification, recipient: u1, notifiable: create(:comment))
    create(:notification, recipient: u2, notifiable: create(:comment))

    visit project_notifications_path(@project)

    expect(page).to have_selector '.notification', count: 2
    expect(page).not_to have_content 'You have no notifications yet'
  end

  # TODO in Pro test that the page only shows notifs for *current* project
end
