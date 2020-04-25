require 'rails_helper'

describe EditorChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    # initialize connection with identifiers
    stub_connection current_user: user
  end

  it 'with no resource the subscription is rejected' do
    subscribe

    expect(subscription).to be_rejected
  end

  it 'rejects when resource is not found' do
    resource = create(:issue)
    subscribe(resource_id: '42', resource_type: resource.model_name.param_key)

    expect(subscription).to be_rejected
  end

  it 'rejects when resource is not proper type' do
    resource = create(:list)
    subscribe(resource_id: resource.id, resource_type: resource.model_name.param_key)

    expect(subscription).to be_rejected
  end

  it 'accepts evidence, issues, notes, and cards' do
    [create(:evidence), create(:issue), create(:note), create(:card)].each do |resource|
      subscribe(resource_id: resource.id, resource_type: resource.model_name.param_key)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for [user, Project.new, resource]
    end
  end
end
