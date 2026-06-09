require 'rails_helper'

describe 'Grammar suggestions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  let(:roslin_agent) do
    instance_double(Dradis::Plugins::Echo::Agent,
                    enabled?: true,
                    env: { 'LANGUAGETOOL_ADDRESS' => 'http://languagetool:8081' })
  end

  let(:service_double) do
    instance_double(
      Dradis::Plugins::Echo::LanguageToolService,
      call: [
        {
          field_name: 'Title',
          offset: 0,
          length: 4,
          message: 'Possible spelling mistake',
          exact: 'tset',
          replacements: ['test']
        }
      ]
    )
  end

  before do
    allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:instance).and_return(roslin_agent)
    allow(Dradis::Plugins::Echo::LanguageToolService).to receive(:new).and_return(service_double)
  end

  describe 'POST /addons/echo/projects/:project_id/grammar_suggestions' do
    it 'returns grammar matches for a project issue' do
      post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['message']).to eq('Possible spelling mistake')
      expect(json.first['field_name']).to eq('Title')
    end

    it 'passes the configured LanguageTool address to the service' do
      post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id
      }

      expect(Dradis::Plugins::Echo::LanguageToolService).to have_received(:new).with(
        hash_including(address: 'http://languagetool:8081')
      )
    end

    context 'when raw text is provided' do
      it 'checks the provided text instead of the persisted content' do
        raw_text = "#[Title]#\nUnsaved speling mistake\n"

        post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
          commentable_type: 'Issue',
          commentable_id: issue.id,
          text: raw_text
        }

        expect(Dradis::Plugins::Echo::LanguageToolService).to have_received(:new).with(
          hash_including(fields: FieldParser.source_to_fields(raw_text))
        )
      end
    end

    context 'when an empty text param is provided' do
      it 'checks the empty text rather than falling back to persisted content' do
        post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
          commentable_type: 'Issue',
          commentable_id: issue.id,
          text: ''
        }

        expect(Dradis::Plugins::Echo::LanguageToolService).to have_received(:new).with(
          hash_including(fields: {})
        )
      end
    end

    it 'returns 404 for an issue outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect {
        post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
          commentable_type: 'Issue',
          commentable_id: other_issue.id
        }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 422 for an invalid commentable_type' do
      post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
        commentable_type: 'User',
        commentable_id: 1
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 503 when LanguageTool is unavailable' do
      allow(service_double).to receive(:call)
        .and_raise(Dradis::Plugins::Echo::LanguageToolService::UnavailableError, 'Connection refused')

      post "/addons/echo/projects/#{@project.id}/grammar_suggestions", params: {
        commentable_type: 'Issue',
        commentable_id: issue.id
      }

      expect(response).to have_http_status(:service_unavailable)
    end
  end
end
