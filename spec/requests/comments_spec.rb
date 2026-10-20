require 'rails_helper'

describe 'comments' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }
  let(:comment_params) { { commentable_type: 'Issue', commentable_id: issue.id } }

  describe 'GET /comments' do
    let(:get_comments) { get '/comments', params: { comment: comment_params } }
    let(:page) { Capybara.string(response.body) }

    describe 'comment count' do
      it 'hides the count when there are no comments' do
        get_comments

        expect(page).to have_css('[data-behavior~=comment-count].d-none', text: '0')
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
