shared_examples 'inline threads' do
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

  let(:turbo_stream_headers) do
    { 'Accept' => 'text/vnd.turbo-stream.html' }
  end

  describe 'GET /inline_threads' do
    it 'returns threads as JSON' do
      thread = create(:inline_thread, commentable: commentable)
      create(:comment, inline_thread: thread, commentable: commentable)

      get inline_threads_path(
        format: :json,
        inline_thread: {
          commentable_type: commentable.class.to_s,
          commentable_id: commentable.id
        }
      )

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['id']).to eq(thread.id)
      expect(json.first['anchor']['exact']).to eq('Apache bugs')
      expect(json.first['comments'].length).to eq(1)
    end

    it 'returns empty array when no threads exist' do
      get inline_threads_path(
        format: :json,
        inline_thread: {
          commentable_type: commentable.class.to_s,
          commentable_id: commentable.id
        }
      )

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe 'GET /inline_threads/:id' do
    it 'renders the thread in a turbo frame' do
      thread = create(:inline_thread, commentable: commentable)
      create(:comment, inline_thread: thread, commentable: commentable)

      get inline_thread_path(thread)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('turbo-frame')
      expect(response.body).to include(thread.quoted_text)
    end
  end

  describe 'POST /inline_threads' do
    it 'creates a new thread with initial comment' do
      expect {
        post inline_threads_path,
          params: {
            inline_thread: {
              commentable_type: commentable.class.to_s,
              commentable_id: commentable.id,
              anchor: valid_anchor.to_json,
              comments_attributes: { '0' => { content: 'This needs revision' } }
            }
          },
          headers: turbo_stream_headers
      }.to change { InlineThread.count }.by(1)
        .and change { Comment.count }.by(1)

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')

      thread = InlineThread.last
      expect(thread.commentable).to eq(commentable)
      expect(thread.user).to eq(@logged_in_as)
      expect(thread.anchor['exact']).to eq('Apache bugs')
      expect(thread).to be_open

      comment = thread.comments.first
      expect(comment.content).to eq('This needs revision')
      expect(comment.commentable).to eq(commentable)
    end
  end

  describe 'DELETE /inline_threads/:id' do
    it 'destroys a thread owned by the current user' do
      thread = create(:inline_thread, commentable: commentable, user: @logged_in_as)

      expect {
        delete inline_thread_path(thread),
          headers: turbo_stream_headers
      }.to change { InlineThread.count }.by(-1)

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    end
  end

  describe 'POST /inline_threads/:id/resolution' do
    it 'resolves the thread' do
      thread = create(:inline_thread, commentable: commentable)

      post inline_thread_resolution_path(thread),
        headers: turbo_stream_headers

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(thread.reload).to be_resolved
      expect(thread.resolved_by).to eq(@logged_in_as)
      expect(thread.resolved_at).to be_present
    end
  end

  describe 'DELETE /inline_threads/:id/resolution' do
    it 'reopens a resolved thread' do
      thread = create(
        :inline_thread,
        commentable: commentable,
        status: :resolved,
        resolved_by: @logged_in_as,
        resolved_at: Time.current
      )

      delete inline_thread_resolution_path(thread),
        headers: turbo_stream_headers

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(thread.reload).to be_open
      expect(thread.resolved_by).to be_nil
    end
  end

  describe 'POST /inline_threads/:id/comments' do
    it 'creates a reply comment on the thread' do
      thread = create(:inline_thread, commentable: commentable)

      expect {
        post inline_thread_comments_path(thread),
          params: { comment: { content: 'Good point, will fix' } },
          headers: turbo_stream_headers
      }.to change { thread.comments.count }.by(1)

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')

      comment = thread.comments.last
      expect(comment.content).to eq('Good point, will fix')
      expect(comment.commentable).to eq(commentable)
      expect(comment.user).to eq(@logged_in_as)
    end
  end
end
