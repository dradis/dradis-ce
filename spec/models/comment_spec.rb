require 'rails_helper'

describe Comment do
  it { should belong_to :commentable }
  it { should belong_to :user }

  it { should validate_presence_of :commentable }
  it { should validate_presence_of :content }
  it { should validate_presence_of :user }

  it 'does not create a subscription when created by the commentable author' do
    user  = create(:user)
    issue = create(:issue, author: user.email)
    expect do
      Comment.create(commentable: issue, content: 'rspec content', user: user)
    end.to change { Subscription.count }.by(0)
  end

  it 'creates a subscription when not created by the commentable author' do
    user  = create(:user)
    issue = create(:issue)
    expect do
      Comment.create(commentable: issue, content: 'rspec content', user: user)
    end.to change { Subscription.count }.by(1)
  end
end
