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

    it 'renders a frame that loads the subscriptions header from the subscriptions controller' do
      get_comments

      frame = page.find("turbo-frame#subscriptions_issue_#{issue.id}")
      expect(frame['src']).to eq(subscriptions_path(subscription: { subscribable_type: 'Issue', subscribable_id: issue.id }))
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
