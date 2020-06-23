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

# Define the following let variables before using these examples:
#   - subscribable: an instance of the subscribable model
#
shared_examples 'a page with subscribe/unsubscribe links' do
  it 'subscribes and unsubscribes with the provided links' do

    within('.dots-container') do
      find('.dots-dropdown').click
      click_link 'Subscribe'
    end

    expect(page).to have_text 'Subscribed!'
    expect(
      Subscription.find_by(
        user: @logged_in_as,
        subscribable_type: subscribable.class.to_s,
        subscribable_id: subscribable.id
      )
    ).not_to be nil

    within('.dots-container') do
      find('.dots-dropdown').click
      click_link 'Unsubscribe'
    end

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
