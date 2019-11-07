require 'rails_helper'

describe NotificationGroup do
  before do
    @user = create(:user)
    @issue = create(:issue)
    @comment = create(:comment, commentable: @issue)
    @notification = create(:notification, notifiable: @comment, recipient: @user)
    @user_notifications = @user.notifications.since
  end

  describe '#new' do
    it 'creates a grouped hash of notifications' do
      expected_hash = {
        Project.new => [ [@issue, [@notification]] ]
      }
      group = NotificationGroup.new(@user_notifications)
      expect(group.to_h.values).to eq(expected_hash.values)
    end
  end

  describe '#count' do
    before do
      @comment2 = create(:comment, commentable: @issue)
      @notification2 = create(:notification, notifiable: @comment2, recipient: @user)
    end

    it 'correctly counts the total number of notifications' do
      group = NotificationGroup.new(@user_notifications)
      expect(group.count).to eq(2)
    end
  end
end
