require 'rails_helper'

describe Comment do
  it { should belong_to :commentable }
  it { should belong_to :user }

  it { should validate_presence_of :commentable }
  it { should validate_presence_of :content }
  it { should validate_presence_of :user }

  it 'subscribes the comment author to the commentable' do
    user  = create(:user)
    issue = create(:issue)
    expect do
      Comment.create(commentable: issue, content: 'rspec content', user: user)
    end.to change { Subscription.count }.by(1)
  end

  describe '#mentions' do
    it 'detects mentions' do
      user1   = create(:user, email: 'foo')
      user2   = create(:user, email: 'bar')
      comment = create(:comment, content: 'Hello @foo and hello @bar')

      expect(comment.send(:mentions)).to eq [user1, user2]
    end
  end
end
