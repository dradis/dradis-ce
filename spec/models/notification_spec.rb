require 'rails_helper'

describe Notification do
  it { should belong_to :actor }
  it { should belong_to :notifiable }
  it { should belong_to :recipient }

  it { should validate_presence_of :action }
  it { should validate_presence_of :actor }
  it { should validate_presence_of :notifiable }
  it { should validate_presence_of :recipient }

  describe 'since' do
    before do
      @user = create(:user)
      @issue = create(:issue)
      @comment1 = create(:comment, commentable: @issue)
      @notification1 = create(:notification, notifiable: @comment1, recipient: @user, created_at: Time.now - 3.minutes)

      @comment2 = create(:comment, commentable: @issue)
      @notification2 = create(:notification, notifiable: @comment2, recipient: @user, created_at: Time.now - 10.minutes)
    end

    it 'returns all the unread notifications within a span of time' do
      current_notifications = @user.notifications.since(5.minutes.ago)

      expect(current_notifications).to include(@notification1)
      expect(current_notifications).to_not include(@notification2)
    end
  end
end
