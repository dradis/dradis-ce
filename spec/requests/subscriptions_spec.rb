require 'rails_helper'

describe 'subscriptions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }
  let(:params) { { subscription: { subscribable_type: 'Issue', subscribable_id: issue.id } } }
  let(:frame_headers) { { 'Turbo-Frame' => "subscriptions_issue_#{issue.id}" } }

  describe 'GET /subscriptions' do
    let(:page) { Capybara.string(response.body) }

    before do
      subscribers.each do |user|
        Subscription.subscribe(user: user, to: issue)
      end

      get '/subscriptions', params: params, headers: frame_headers
    end

    context 'when there are no subscribers' do
      let(:subscribers) { [] }

      it 'only shows the subscribe link' do
        expect(page).to have_link('Subscribe')
        expect(page).not_to have_link('Unsubscribe')
        expect(page).not_to have_css('[data-behavior~=subscribers]')
      end
    end

    context 'when there are up to 4 subscribers' do
      let(:subscribers) { create_list(:user, 3) }

      it 'shows an avatar for each subscriber' do
        expect(page).to have_css('[data-behavior~=subscribers] .gravatar', count: 3)
        expect(page).not_to have_css('[data-behavior~=subscribers-overflow]')
      end
    end

    context 'when there are more than 4 subscribers' do
      let(:subscribers) { create_list(:user, 6) }

      it 'shows 4 avatars and the number of remaining subscribers' do
        expect(page).to have_css('[data-behavior~=subscribers] .gravatar', count: 4)
        expect(page).to have_css('[data-behavior~=subscribers-overflow]', text: '+2')
      end

      it 'names the remaining subscribers in the overflow tooltip' do
        expect(page.find('[data-behavior~=subscribers-overflow]')['data-bs-title']).to eq(subscribers.last(2).map(&:name).join(', '))
      end
    end
  end

  describe 'POST /subscriptions' do
    it 'subscribes the current user and redirects back for regular requests' do
      expect do
        post '/subscriptions', params: params
      end.to change(Subscription, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it 'sends Turbo Frame requests to the subscriptions header' do
      post '/subscriptions', params: params, headers: frame_headers

      expect(response).to redirect_to(subscriptions_path(params))
      expect(response).to have_http_status(:see_other)
    end

    it 'sends Turbo Frame requests to the subscriptions header when the user is already subscribed' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      expect do
        post '/subscriptions', params: params, headers: frame_headers
      end.not_to change(Subscription, :count)

      expect(response).to redirect_to(subscriptions_path(params))
    end
  end

  describe 'DELETE /subscriptions/:id' do
    it 'unsubscribes the current user and sends Turbo Frame requests to the subscriptions header' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      expect do
        delete "/subscriptions/#{issue.id}", params: params, headers: frame_headers
      end.to change(Subscription, :count).by(-1)

      expect(response).to redirect_to(subscriptions_path(params))
      expect(response).to have_http_status(:see_other)
    end

    it 'sends Turbo Frame requests to the subscriptions header when the user is no longer subscribed' do
      expect do
        delete "/subscriptions/#{issue.id}", params: params, headers: frame_headers
      end.not_to change(Subscription, :count)

      expect(response).to redirect_to(subscriptions_path(params))
    end
  end
end
