require 'rails_helper'

describe 'User notifications', js: true do
  subject { page }

  before do
    login_to_project_as_user
    visit project_path(@project)
  end

  it 'can view the notifcation bell' do
    within '.navbar' do
      expect(page).to have_css '.notifications.dropdown'
    end
  end

  describe 'notifications list with ajax' do
    it 'opens the dropdown after click' do
      find('[data-behavior~=notifications-dropdown]').click
      expect(find('[data-behavior~=notifications-dropdown] + div')).to_not be_nil
    end

    context 'the user has no notifications' do
      it 'shows an empty dropdown' do
        find('[data-behavior~=notifications-dropdown]').click

        expect(find("li", text: "You don't have any notifications yet.")).to_not be_nil
      end
    end

    context 'the user has some notifications' do
      it 'shows the notification list' do
        issue = create(:issue, text: 'Test issue')
        comment = create(:comment, commentable: issue, user: @logged_in_as)
        create(:notification, notifiable: comment, actor: @logged_in_as, recipient: @logged_in_as)

        find('[data-behavior~=notifications-dropdown]').click

        expect(page).to have_content("#{@logged_in_as.email} commented")
      end
    end
  end

  describe 'notification reading' do
    before do
      issue = create(:issue, text: 'Test issue')
      comment1 = create(:comment, commentable: issue, user: @logged_in_as)
      @notification1 = create(:notification, notifiable: comment1, actor: @logged_in_as, recipient: @logged_in_as)
      comment2 = create(:comment, commentable: issue, user: @logged_in_as)
      @notification2 = create(:notification, notifiable: comment2, actor: @logged_in_as, recipient: @logged_in_as)

      find('[data-behavior~=notifications-dropdown]').click
    end

    describe 'read all feature' do
      it 'sets all the notifications as read' do
        click_link 'Mark all as read'

        expect(page).to_not have_css(".notification.unread[data-notification-id='#{@notification1.id}']")
        expect(page).to_not have_css(".notification.unread[data-notification-id='#{@notification1.id}']")
        expect(@notification1.reload.read_at).to_not be_nil
        expect(@notification2.reload.read_at).to_not be_nil
      end
    end

    describe 'read notification feature' do
      it 'sets a notification as read' do
        within ".notification[data-notification-id='#{@notification1.id}']" do
          click_link 'Mark as read'
        end

        expect(page).to_not have_css(".notification.unread[data-notification-id='#{@notification1.id}']")
        expect(@notification1.reload.read_at).to_not be_nil
      end
    end
  end
end
