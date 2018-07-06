require 'rails_helper'

describe Subscription do
  it { should belong_to :subscribable }
  it { should belong_to :user }

  it { should validate_presence_of :subscribable }
  it { should validate_presence_of :user }

  it 'prevents subscribing to the same subscribable twice' do
    user = create(:user)
    subscribable = create(:issue, author: user.email)

    expect do
      Subscription.subscribe(to: subscribable, user: user)
    end.to change { Subscription.count }.by(0)
  end
end
