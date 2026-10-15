require 'rails_helper'

describe 'comments' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  describe 'GET /comments' do
    let(:get_comments) do
      get '/comments',
        params: { comment: { commentable_type: 'Issue', commentable_id: issue.id } }
    end

    it 'shows a subscribe button when the user is not subscribed' do
      get_comments

      expect(response.body).to include('Subscribe')
      expect(response.body).not_to include('Unsubscribe')
    end

    it 'shows an unsubscribe button when the user is subscribed' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      get_comments

      expect(response.body).to include('Unsubscribe')
    end

    describe 'comment count' do
      let(:page) { Capybara.string(response.body) }

      it 'hides the count when there are no comments' do
        get_comments

        expect(page).to have_css('[data-behavior~=comment-count].d-none', text: '0')
        expect(page).not_to have_text('There have been no comments yet.')
      end

      it 'shows the count when there are comments' do
        create_list(:comment, 2, commentable: issue)

        get_comments

        expect(page).to have_css('[data-behavior~=comment-count]:not(.d-none)', text: '2')
      end
    end

    describe 'subscribers' do
      let(:page) { Capybara.string(response.body) }

      before do
        subscribers.each do |user|
          Subscription.subscribe(user: user, to: issue)
        end

        get_comments
      end

      context 'when there are no subscribers' do
        let(:subscribers) { create_list(:user, 0) }

        it 'only shows the subscribe button' do
          expect(page).not_to have_css('[data-behavior~=subscribers]')
        end
      end

      context 'when there are up to 4 subscribers' do
        let(:subscribers) { create_list(:user, 3) }

        it 'shows an avatar for each subscriber' do
          expect(page).to have_css('[data-behavior~=subscribers-toggle] .gravatar', count: 3)
          expect(page).not_to have_css('[data-behavior~=subscribers-overflow]')
        end
      end

      context 'when there are more than 4 subscribers' do
        let(:subscribers) { create_list(:user, 6) }

        it 'shows 4 avatars and the number of remaining subscribers' do
          expect(page).to have_css('[data-behavior~=subscribers-toggle] .gravatar', count: 4)
          expect(page).to have_css('[data-behavior~=subscribers-overflow]', text: '+2')
        end

        it 'lists every subscriber in the dropdown' do
          expect(page).to have_css('[data-behavior~=subscribers] .dropdown-item-text', count: 6)
        end

        it 'summarises the remaining subscribers in the tooltip' do
          expect(page).to have_css('[data-behavior~=subscribers] [data-bs-toggle=tooltip][title$="and 2 others"]')
        end
      end

      context 'when the current user is subscribed' do
        let(:subscribers) { [@logged_in_as] }

        it 'marks the current user in the dropdown' do
          expect(page).to have_css('[data-behavior~=subscribers] .dropdown-item-text', text: /#{Regexp.escape(@logged_in_as.name)}\s+\(you\)/)
        end
      end
    end
  end
end
