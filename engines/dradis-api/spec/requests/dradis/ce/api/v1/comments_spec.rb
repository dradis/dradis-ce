require 'rails_helper'

describe 'Comments API' do

  include_context 'project scoped API'
  include_context 'https'

  let(:issue) { create(:issue) } # a generic commentable

  context 'as unauthenticated user' do
    let(:comment) { create(:comment) }

    describe 'GET /api/issues/:issue_id/comments' do
      it "throws 401" do
        get "/api/issues/#{issue.id}/comments", env: @env
        expect(response.status).to eq 401
      end
    end
    describe 'GET /api/issues/:issue_id/comments/:id' do
      it 'throws 401' do
        get "/api/issues/#{issue.id}/comments/#{comment.id}", env: @env
        expect(response.status).to eq 401
      end
    end
    describe 'POST /api/issues/:issue_id/comments' do
      it 'throws 401' do
        post "/api/issues/#{issue.id}/comments", env: @env
        expect(response.status).to eq 401
      end
    end
    describe 'PUT /api/issues/:issue_id/comments/:id' do
      it 'throws 401' do
        put "/api/issues/#{issue.id}/comments/1", env: @env
        expect(response.status).to eq 401
      end
    end
    describe 'PATCH /api/issues/:issue_id/comments/:id' do
      it 'throws 401' do
        put "/api/issues/#{issue.id}/comments/1", env: @env
        expect(response.status).to eq 401
      end
    end
    describe 'DELETE /api/issues/:issue_id/comments/:id' do
      it 'throws 401' do
        delete "/api/issues/#{issue.id}/comments/1", env: @env
        expect(response.status).to eq 401
      end
    end
  end

  context 'as authenticated user' do
    include_context 'authenticated API user'

    describe 'GET /api/issues/:issue_id/comments' do
      before do
        @comments = [
          create(:comment, commentable: issue, content: 'Comment 1'),
          create(:comment, commentable: issue, content: 'Comment 2'),
          create(:comment, commentable: issue, content: 'Comment 3')
        ]
        @other_comment = create(:comment)

        get "/api/issues/#{issue.id}/comments", env: @env
      end

      let(:retrieved_comments) { JSON.parse(response.body) }

      it 'responds with HTTP code 200' do
        expect(response.status).to eq(200)
      end

      it 'retrieves all the comments for the given commentable' do
        expect(retrieved_comments.count).to eq 3
        retrieved_content = retrieved_comments.map { |json| json['content'] }
        expect(retrieved_content).to match_array(@comments.map(&:content))
      end

      it "doesn't return comments from other commentables" do
        retrieved_ids = retrieved_comments.map { |n| n['id'] }
        expect(retrieved_ids).not_to include @other_comment.id
      end
    end

    describe 'GET /api/issues/:issue_id/comments/:id' do
      before do
        @comment = create(:comment, commentable: issue)

        get "/api/issues/#{issue.id}/comments/#{@comment.id}", env: @env
      end

      it 'responds with HTTP code 200' do
        expect(response.status).to eq 200
      end

      it 'returns JSON information about the comment' do
        retrieved_comment = JSON.parse(response.body)
        expect(retrieved_comment['id']).to eq @comment.id
        expect(retrieved_comment['content']).to eq @comment.content
        expect(retrieved_comment['user_id']).to eq @comment.user_id
      end
    end

    describe 'POST /api/issues/:issue_id/comments' do
      let(:url) { "/api/issues/#{issue.id}/comments" }
      let(:post_comment) { post url, params: params.to_json, env: @env }

      context 'when content_type header = application/json' do
        include_context 'content_type: application/json'

        context 'with params for a valid comment' do
          let(:params) { { comment: { content: 'New comment' } } }

          it 'responds with HTTP code 201' do
            post_comment
            expect(response.status).to eq 201
          end

          let(:submit_form) { post_comment }
          include_examples 'creates an Activity', :create, Comment

          it 'creates a comment' do
            expect { post_comment }.to change { issue.comments.count }.by(1)
          end

          it 'returns the attributes of the new comment as JSON' do
            post_comment
            retrieved_comment = JSON.parse(response.body)
            params[:comment].each do |attr, value|
              expect(retrieved_comment[attr.to_s]).to eq value
            end
            expect(response.location).to eq(
              dradis_api.issue_comment_url(issue, retrieved_comment['id'])
            )
          end
        end

        context 'with params for an invalid comment' do
          let(:params) { { comment: { content: 'a' * 65536 } } } # too long

          it 'responds with HTTP code 422' do
            post_comment
            expect(response.status).to eq 422
          end

          it "doesn't create a comment" do
            expect { post_comment }.not_to change { Comment.count }
          end
        end

        context 'when no :comment param is sent' do
          let(:params) { {} }

          it "doesn't create a comment" do
            expect { post_comment }.not_to change { Comment.count }
          end

          it 'responds with HTTP code 422' do
            post_comment
            expect(response.status).to eq(422)
          end
        end

        context 'when invalid JSON is sent' do
          it 'responds with HTTP code 400' do
            json_payload = '{"content":{"content":"A malformed label", , }}'
            post url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context 'when JSON is not sent' do
        it 'responds with HTTP code 415' do
          params = { comment: {} }
          post url, params: params, env: @env
          expect(response.status).to eq(415)
        end
      end
    end

    describe 'PUT /api/issues/:issue_id/comments/:id' do
      let(:comment) do
        create(:comment, commentable: issue, content: 'My content')
      end

      let(:url) { "/api/issues/#{issue.id}/comments/#{comment.id}" }
      let(:put_comment) { put url, params: params.to_json, env: @env }

      context 'when content_type header = application/json' do
        include_context 'content_type: application/json'

        context 'with params for a valid comment' do
          let(:params) { { comment: { content: 'New content' } } }

          it 'responds with HTTP code 200' do
            put_comment
            expect(response.status).to eq 200
          end

          it 'updates the comment' do
            put_comment
            expect(comment.reload.content).to eq 'New content'
          end

          let(:submit_form) { put_comment }
          let(:model) { comment }
          include_examples 'creates an Activity', :update

          it 'returns the attributes of the updated comment as JSON' do
            put_comment
            retrieved_comment = JSON.parse(response.body)
            expect(retrieved_comment['content']).to eq 'New content'
          end
        end

        context 'with params for an invalid comment' do
          let(:params) { { comment: { content: 'a' * 65536 } } } # too long

          it 'responds with HTTP code 422' do
            put_comment
            expect(response.status).to eq 422
          end

          it "doesn't update the comment" do
            expect { put_comment }.not_to change { comment.reload.attributes }
          end
        end

        context 'when no :comment param is sent' do
          let(:params) { {} }

          it "doesn't update the comment" do
            expect { put_comment }.not_to change { comment.reload.attributes }
          end

          it 'responds with HTTP code 422' do
            put_comment
            expect(response.status).to eq 422
          end
        end

        context 'when invalid JSON is sent' do
          it 'responds with HTTP code 400' do
            json_payload = '{"comment":{"content":"A malformed label", , }}'
            put url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context 'when JSON is not sent' do
        let(:params) { { comment: { text: 'New content' } } }

        it 'responds with HTTP code 415' do
          expect { put url, params: params, env: @env }.not_to change { comment.reload.attributes }
          expect(response.status).to eq 415
        end
      end
    end

    describe 'DELETE /api/issues/:issues_id/comments/:id' do
      let(:comment) { create(:comment, commentable: issue, content: 'My Content') }

      let(:delete_comment) do
        delete "/api/issues/#{issue.id}/comments/#{comment.id}", env: @env
      end

      it 'deletes the comment' do
        comment_id = comment.id
        delete_comment
        expect(Comment.find_by_id(comment_id)).to be_nil
      end

      it 'responds with error code 200' do
        delete_comment
        expect(response.status).to eq(200)
      end

      let(:submit_form) { delete_comment }
      let(:model) { comment }
      include_examples 'creates an Activity', :destroy

      it 'returns JSON with a success message' do
        delete_comment
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq\
          'Resource deleted successfully'
      end
    end
  end
end
