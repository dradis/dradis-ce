require 'rails_helper'

describe Notification do
  it { should belong_to :actor }
  it { should belong_to :notifiable }
  it { should belong_to :recipient }

  it { should validate_presence_of :action }
  it { should validate_presence_of :actor }
  it { should validate_presence_of :notifiable }
  it { should validate_presence_of :recipient }


  describe '.for_digest' do
    before do
      @user = create(:user)
      @issue = create(:issue)
      @comment = create(:comment, commentable: @issue)
      @notification = create(:notification, notifiable: @comment, read_at: nil, recipient: @user)
    end

    it 'creates a grouped hash of notifications' do
      expected_hash = {
        1 => [ [@issue, [@notification]] ]
      }
      expect(@user.notifications.for_digest(1.day)).to eq(expected_hash)
    end
  end
end
