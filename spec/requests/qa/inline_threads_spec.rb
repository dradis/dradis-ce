require 'rails_helper'

describe 'QA Inline Threads' do
  before do
    login_to_project_as_user
    @issue = create(:issue, state: :ready_for_review)
  end

  let(:valid_anchor) do
    {
      type: 'TextQuoteSelector',
      exact: 'Apache bugs',
      prefix: '#[Title]#\nRspec multiple ',
      suffix: '\n\n#[Description]#',
      position: { start: 28, end: 39 },
      field_name: 'Title'
    }
  end

  describe 'GET /projects/:project_id/qa/issues/:issue_id/inline_threads' do
    it 'returns threads as JSON' do
      thread = create(:inline_comment_thread, issue: @issue)
      create(:comment, inline_comment_thread: thread, commentable: @issue)

      get project_qa_issue_inline_threads_path(@project, @issue, format: :json)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['id']).to eq(thread.id)
      expect(json.first['anchor']['exact']).to eq('Apache bugs')
      expect(json.first['comments'].length).to eq(1)
    end

    it 'returns empty array when no threads exist' do
      get project_qa_issue_inline_threads_path(@project, @issue, format: :json)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe 'POST /projects/:project_id/qa/issues/:issue_id/inline_threads' do
    it 'creates a new thread with initial comment' do
      expect {
        post project_qa_issue_inline_threads_path(@project, @issue, format: :js),
          params: {
            inline_comment_thread: { anchor: valid_anchor },
            comment: { content: 'This needs revision' }
          }
      }.to change { InlineCommentThread.count }.by(1)
        .and change { Comment.count }.by(1)

      thread = InlineCommentThread.last
      expect(thread.issue).to eq(@issue)
      expect(thread.user).to eq(@logged_in_as)
      expect(thread.anchor['exact']).to eq('Apache bugs')
      expect(thread).to be_open

      comment = thread.comments.first
      expect(comment.content).to eq('This needs revision')
      expect(comment.commentable).to eq(@issue)
    end

    it 'creates a thread without initial comment' do
      expect {
        post project_qa_issue_inline_threads_path(@project, @issue, format: :js),
          params: { inline_comment_thread: { anchor: valid_anchor } }
      }.to change { InlineCommentThread.count }.by(1)
        .and change { Comment.count }.by(0)
    end
  end

  describe 'DELETE /projects/:project_id/qa/issues/:issue_id/inline_threads/:id' do
    it 'destroys a thread owned by the current user' do
      thread = create(:inline_comment_thread, issue: @issue, user: @logged_in_as)

      expect {
        delete project_qa_issue_inline_thread_path(@project, @issue, thread, format: :js)
      }.to change { InlineCommentThread.count }.by(-1)
    end
  end

  describe 'POST /projects/:project_id/qa/issues/:issue_id/inline_threads/:id/resolution' do
    it 'resolves the thread' do
      thread = create(:inline_comment_thread, issue: @issue)

      post project_qa_issue_inline_thread_resolution_path(@project, @issue, thread, format: :js)

      expect(thread.reload).to be_resolved
      expect(thread.resolved_by).to eq(@logged_in_as)
      expect(thread.resolved_at).to be_present
    end
  end

  describe 'DELETE /projects/:project_id/qa/issues/:issue_id/inline_threads/:id/resolution' do
    it 'reopens a resolved thread' do
      thread = create(
        :inline_comment_thread,
        issue: @issue,
        status: :resolved,
        resolved_by: @logged_in_as,
        resolved_at: Time.current
      )

      delete project_qa_issue_inline_thread_resolution_path(@project, @issue, thread, format: :js)

      expect(thread.reload).to be_open
      expect(thread.resolved_by).to be_nil
    end
  end

  describe 'POST /projects/:project_id/qa/issues/:issue_id/inline_threads/:id/comments' do
    it 'creates a reply comment on the thread' do
      thread = create(:inline_comment_thread, issue: @issue)

      expect {
        post project_qa_issue_inline_thread_comments_path(@project, @issue, thread, format: :js),
          params: { comment: { content: 'Good point, will fix' } }
      }.to change { thread.comments.count }.by(1)

      comment = thread.comments.last
      expect(comment.content).to eq('Good point, will fix')
      expect(comment.commentable).to eq(@issue)
      expect(comment.user).to eq(@logged_in_as)
    end
  end
end
