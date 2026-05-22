require 'rails_helper'

describe 'Grammar checks' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  let(:service_double) do
    instance_double(
      Dradis::Plugins::Echo::LanguageToolService,
      call: [
        {
          field_name:   'Title',
          offset:       0,
          length:       4,
          message:      'Possible spelling mistake',
          exact:        'tset',
          replacements: ['test']
        }
      ]
    )
  end

  before do
    allow(Dradis::Plugins::Echo::LanguageToolService).to receive(:new).and_return(service_double)
  end

  describe 'POST /addons/echo/projects/:project_id/grammar_check' do
    it 'returns grammar matches for a project issue' do
      post "/addons/echo/projects/#{@project.id}/grammar_check", params: {
        commentable_type: 'Issue',
        commentable_id:   issue.id
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['message']).to eq('Possible spelling mistake')
      expect(json.first['field_name']).to eq('Title')
    end

    it 'returns 404 for an issue outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect {
        post "/addons/echo/projects/#{@project.id}/grammar_check", params: {
          commentable_type: 'Issue',
          commentable_id:   other_issue.id
        }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 422 for an invalid commentable_type' do
      post "/addons/echo/projects/#{@project.id}/grammar_check", params: {
        commentable_type: 'User',
        commentable_id:   1
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
