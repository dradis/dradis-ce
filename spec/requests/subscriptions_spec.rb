require 'rails_helper'

describe 'subscriptions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  describe 'POST /subscriptions' do
    it 'subscribes the current user to the subscribable' do
      expect do
        post '/subscriptions',
          params: { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } }
      end.to change(Subscription, :count).by(1)
    end
  end
end
