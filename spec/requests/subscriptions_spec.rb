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

    it 'ignores the request if the user is already subscribed' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      expect do
        post '/subscriptions',
          params: { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } }
      end.not_to change(Subscription, :count)

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'DELETE /subscriptions/:id' do
    it 'ignores the request if the user is already unsubscribed' do
      delete "/subscriptions/#{issue.id}",
        params: { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } }

      expect(response).to have_http_status(:redirect)
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
