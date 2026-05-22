require 'rails_helper'

describe 'Grammar replacements' do
  before { login_to_project_as_user }

  let(:issue) do
    create(:issue,
      node: @project.issue_library,
      text: "#[Title]#\ntset\n\n#[Description]#\nSome body text"
    )
  end

  describe 'POST /addons/echo/projects/:project_id/grammar_replacements' do
    it 'applies the replacement and returns the updated raw text' do
      post "/addons/echo/projects/#{@project.id}/grammar_replacements", params: {
        commentable_type: 'Issue',
        commentable_id:   issue.id,
        field_name:       'Title',
        offset:           0,
        length:           4,
        replacement:      'test'
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['raw']).to include('test')
      expect(issue.reload.text).to include('test')
    end

    it 'returns 404 for an issue outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect {
        post "/addons/echo/projects/#{@project.id}/grammar_replacements", params: {
          commentable_type: 'Issue',
          commentable_id:   other_issue.id,
          field_name:       'Title',
          offset:           0,
          length:           4,
          replacement:      'test'
        }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 422 for an invalid commentable_type' do
      post "/addons/echo/projects/#{@project.id}/grammar_replacements", params: {
        commentable_type: 'User',
        commentable_id:   1,
        field_name:       'Title',
        offset:           0,
        length:           4,
        replacement:      'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when field_name does not exist in the record' do
      post "/addons/echo/projects/#{@project.id}/grammar_replacements", params: {
        commentable_type: 'Issue',
        commentable_id:   issue.id,
        field_name:       'NonExistent',
        offset:           0,
        length:           4,
        replacement:      'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
