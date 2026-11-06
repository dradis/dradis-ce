require 'rails_helper'

describe 'comments' do
  include ActionView::RecordIdentifier

  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  describe 'POST /comments' do
    it 'sends the form back with the error when the comment is blank' do
      expect do
        post '/comments',
          params: { comment: { commentable_type: 'Issue', commentable_id: issue.id, content: "  \n " } },
          headers: { 'Accept' => 'text/vnd.turbo-stream.html, text/html' }
      end.not_to change(Comment, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(%(action="replace" target="#{dom_id(issue, :new_comment)}"))
      expect(response.body).not_to include('action="append"')
      expect(response.body).to include('Content can&#39;t be blank')
    end
  end

  describe 'PATCH /comments/:id' do
    let(:comment) { create(:comment, commentable: issue, user: @logged_in_as) }

    it 'sends the form back with the error when the comment is too long' do
      patch "/comments/#{comment.id}", params: { comment: { content: 'a' * (DB_MAX_TEXT_LENGTH + 1) } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(%(id="#{dom_id(comment, :frame)}"))
      expect(response.body).to include('Content is too long')
    end
  end
end
