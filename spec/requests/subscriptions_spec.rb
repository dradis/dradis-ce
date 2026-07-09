require 'rails_helper'

describe 'subscriptions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  describe 'POST /subscriptions' do
    it 'subscribes the current user to the subscribable' do
      expect {
        post '/subscriptions',
          params: { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } }
      }.to change(Subscription, :count).by(1)
    end
  end

  describe 'GET /subscriptions' do
    it 'lists subscribers for the subscribable' do
      get '/subscriptions',
        params: { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } }

      expect(response).to have_http_status(:ok)
    end
  end
end
