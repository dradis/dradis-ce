# Define the following let variables before using these examples:
#   - subscribable: an instance of the subscribable model
#   - user: the subscribed user
#
shared_examples 'a subscribable model' do
  it 'subscribes the subscribable author to the subscribable' do
    expect(
      Subscription.where(user: user, subscribable: subscribable).count
    ).to eq(1)
  end
end

# Define the following let variables before using these examples:
#   - subscribable: an instance of the subscribable model
#
shared_examples 'a page sith subscribe/unsubscribe links' do
  it 'subscribes and unsubscribes with the provided links' do
    click_link 'Subscribe'
    expect(page).to have_text 'Subscribed!'
    expect(
      Subscription.find_by(
        user: @logged_in_as,
        subscribable_type: subscribable.class.to_s,
        subscribable_id: subscribable.id
      )
    ).not_to be nil

    click_link 'Unsubscribe'
    expect(page).to have_text 'Unsubscribed!'
    expect(
      Subscription.find_by(
        user: @logged_in_as,
        subscribable_type: subscribable.class.to_s,
        subscribable_id: subscribable.id
      )
    ).to be nil
  end
end
