require 'rails_helper'

describe 'subscriptions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }
  let(:params) { { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } } }
  let(:frame_headers) { { 'Turbo-Frame' => "subscriptions_issue_#{issue.id}" } }

  describe 'POST /subscriptions' do
    it 'subscribes the current user to the subscribable' do
      expect do
        post '/subscriptions', params: params
      end.to change(Subscription, :count).by(1)
    end

    it 'redirects back for regular requests' do
      post '/subscriptions', params: params

      expect(response).to redirect_to(root_path)
    end

    it 'renders the comments header for Turbo Frame requests' do
      post '/subscriptions', params: params, headers: frame_headers

      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-frame#subscriptions_issue_#{issue.id}")
      expect(page).to have_link('Unsubscribe')
      expect(page).to have_css('[data-behavior~=subscribers-toggle] .gravatar', count: 1)
    end
  end

  describe 'DELETE /subscriptions/:id' do
    it 'unsubscribes the current user and renders the header for Turbo Frame requests' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      expect do
        delete "/subscriptions/#{issue.id}", params: params, headers: frame_headers
      end.to change(Subscription, :count).by(-1)

      page = Capybara.string(response.body)
      expect(page).to have_link('Subscribe')
      expect(page).not_to have_css('[data-behavior~=subscribers]')
    end

    it 'does nothing when the user is no longer subscribed' do
      delete "/subscriptions/#{issue.id}", params: params

      expect(response).to redirect_to(root_path)
    end
  end
end
