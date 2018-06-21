# Define the following let variables before using these examples:
#   subscribable: an instance of the subscribable model
#   user: the subscribed user
shared_examples 'a subscribable model' do
  it 'subscribes the subscribable author to the subscribable' do
    expect(
      Subscription.where(user: user, subscribable: subscribable).count
    ).to eq(1)
  end
end
