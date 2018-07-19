require 'rails_helper'

RSpec.describe 'notifications index page' do
  before do
    login_to_project_as_user
  end

  let(:me) { @logged_in_as }
  let(:u1) { create(:user) }
  let(:u2) { create(:user) }

  def create_notification(opts = {})
    opts[:notifiable] ||= create(:comment)
    create(:notification, opts)
  end

  example 'when I have no notifications' do
    # other users have notifications but you don't:
    create_notification(recipient: u1)
    create_notification(recipient: u2)

    visit project_notifications_path(@project)

    expect(page).not_to have_selector '.notification'
    expect(page).to have_content 'You have no notifications yet'
  end

  example 'when I have notifications' do
    # my notifications: 1 read, 1 unread
    create_notification(recipient: me)
    create_notification(recipient: me, read_at: Time.now)

    # other people's notifications:
    create_notification(recipient: u1)
    create_notification(recipient: u2)

    visit project_notifications_path(@project)

    expect(page).to have_selector '.notification', count: 2
    expect(page).not_to have_content 'You have no notifications yet'
  end
end
