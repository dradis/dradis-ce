# Define the following let variables before using these examples:
#   - subscribable: a non persisted instance of the subscribable model
#   - user: the subscribed user
#
shared_examples 'a subscribable model' do
  it 'subscribes the subscribable author to the subscribable' do
    expect { subscribable.save }.to change {
      Subscription.count
    }.by(1)
  end
end
