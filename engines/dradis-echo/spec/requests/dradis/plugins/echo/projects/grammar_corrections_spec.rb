require 'rails_helper'

describe 'Grammar corrections' do
  before { login_to_project_as_user }

  let(:roslin_agent) do
    instance_double(Dradis::Plugins::Echo::Agent,
                    enabled?: true,
                    env: { 'LANGUAGETOOL_ADDRESS' => 'http://languagetool:8081' })
  end

  before do
    allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:instance).and_return(roslin_agent)
  end

  let(:issue) do
    create(:issue,
      node: @project.issue_library,
      text: "#[Title]#\ntset\n\n#[Description]#\nSome body text"
    )
  end

  describe 'POST /addons/echo/projects/:project_id/grammar_corrections' do
    it 'applies the replacement and returns the updated raw text' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: 0,
        length: 4,
        replacement: 'test'
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['raw']).to include('test')
      expect(issue.reload.text).to include('test')
    end

    context 'when raw text is provided (unsaved editor content)' do
      it 'applies the replacement to the provided text, not the persisted version' do
        unsaved_text = "#[Title]#\ntset\n\n#[Description]#\nUnsaved edits to description"

        post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
          commentable_type: 'Issue',
          commentable_id: issue.id,
          field_name: 'Title',
          offset: 0,
          length: 4,
          replacement: 'test',
          text: unsaved_text
        }

        expect(response).to have_http_status(:ok)
        saved = issue.reload.text
        expect(saved).to include('test')
        expect(saved).to include('Unsaved edits to description')
      end
    end

    context 'when persist=false (edit mode)' do
      it 'returns the corrected text without saving to the database' do
        post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
          commentable_type: 'Issue',
          commentable_id: issue.id,
          field_name: 'Title',
          offset: 0,
          length: 4,
          replacement: 'test',
          persist: 'false'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['raw']).to include('test')
        expect(issue.reload.text).not_to include('test')
      end
    end

    it 'returns 409 when the exact text does not match the current content' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: 0,
        length: 4,
        replacement: 'test',
        exact: 'xxxx'
      }

      expect(response).to have_http_status(:conflict)
      expect(issue.reload.text).not_to include('test')
    end

    it 'returns 422 when replacement param is missing' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: 0,
        length: 4
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when offset is negative' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: -1,
        length: 4,
        replacement: 'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when offset + length exceeds the field length' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: 0,
        length: 999,
        replacement: 'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 503 when Roslin is disabled' do
      allow(roslin_agent).to receive(:enabled?).and_return(false)

      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'Title',
        offset: 0,
        length: 4,
        replacement: 'test'
      }

      expect(response).to have_http_status(:service_unavailable)
    end

    it 'returns 404 for an issue outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect {
        post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
          commentable_type: 'Issue',
          commentable_id: other_issue.id,
          field_name: 'Title',
          offset: 0,
          length: 4,
          replacement: 'test'
        }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 422 for an invalid commentable_type' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'User',
        commentable_id: 1,
        field_name: 'Title',
        offset: 0,
        length: 4,
        replacement: 'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when field_name does not exist in the record' do
      post "/addons/echo/projects/#{@project.id}/grammar_corrections", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id,
        field_name: 'NonExistent',
        offset: 0,
        length: 4,
        replacement: 'test'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
