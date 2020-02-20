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
      user1   = create(:user, email: 'foo@dradis.test')
      user2   = create(:user, email: 'bar@dradis.test')
      comment = create(:comment, content: 'Hello @foo@dradis.test and hello @bar@dradis.test')

      expect(comment.mentions).to match_array [user1, user2]
    end

    it 'detects admins in mentions' do
      user1   = create(:user, :admin, email: 'admin@dradis.test')
      user2   = create(:user, email: 'foo@dradis.test')
      comment = create(:comment, content: 'Hello @admin@dradis.test and @foo@dradis.test')

      expect(comment.mentions).to match_array [user1, user2]
    end
  end

  describe '#notify' do
    it 'creates notifications when a comment is created' do
      commentable = create(:issue)
      create_list(:subscription, 2, subscribable: commentable)
      comment = create(:comment, commentable: commentable)

      expect {
        comment.notify('create')
      }.to change { Notification.count }.by(2)
    end

    it 'creates notifications when a comment has mentions' do
      issue_owner = create(:user, email: 'owner@dradis.test')
      commentable = create(:issue, author: issue_owner.email)
      create(:subscription, subscribable: commentable)
      mentioned = create(:user, email: 'mentioned@dradis.test')
      comment = create(
        :comment,
        commentable: commentable,
        content: "Hello @#{mentioned.email} and @#{issue_owner.email}"
      )

      expect {
        comment.notify('create')
      }.to change { Notification.count }.by(3) \
      .and change { Subscription.count }.by(1)

      expect(Notification.where(action: 'mention').count).to eq(2)
      expect(Notification.where(action: 'create').count).to eq(1)
    end
  end
end
