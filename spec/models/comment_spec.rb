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
end
