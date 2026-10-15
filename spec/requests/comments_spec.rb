require 'rails_helper'

describe 'comments' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }
  let(:comment_params) { { commentable_type: 'Issue', commentable_id: issue.id } }

  describe 'GET /comments' do
    let(:get_comments) { get '/comments', params: { comment: comment_params } }
    let(:page) { Capybara.string(response.body) }

    it 'shows a subscribe link when the user is not subscribed' do
      get_comments

      expect(page).to have_link('Subscribe')
      expect(page).not_to have_link('Unsubscribe')
    end

    it 'shows an unsubscribe link when the user is subscribed' do
      Subscription.subscribe(user: @logged_in_as, to: issue)

      get_comments

      expect(page).to have_link('Unsubscribe')
    end

    describe 'comment count' do
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
      before do
        subscribers.each do |user|
          Subscription.subscribe(user: user, to: issue)
        end

        get_comments
      end

      context 'when there are no subscribers' do
        let(:subscribers) { [] }

        it 'only shows the subscribe link' do
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

  describe 'POST /comments' do
    it 'shows the updated comment count' do
      create(:comment, commentable: issue)

      post '/comments', params: { comment: comment_params.merge(content: 'New comment') }, xhr: true

      expect(response.body).to include(".text(2).toggleClass('d-none', false)")
    end
  end

  describe 'DELETE /comments/:id' do
    it 'hides the comment count after the last comment is deleted' do
      comment = create(:comment, commentable: issue, user: @logged_in_as)

      delete "/comments/#{comment.id}", xhr: true

      expect(response.body).to include(".text(0).toggleClass('d-none', true)")
    end
  end
end
