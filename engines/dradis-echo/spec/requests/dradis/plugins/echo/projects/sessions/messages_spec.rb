require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo session messages' do
  include ActiveJob::TestHelper

  let(:user) { @logged_in_as }

  before { login_to_project_as_user }

  let(:agent) { create(:agent, enabled: true) }
  let(:issue) { create(:issue, node: @project.issue_library, text: "#[Title]#\nSQLi") }
  let(:session) { create(:echo_session, agent: agent, record: issue) }

  describe 'POST /addons/echo/projects/:project_id/sessions/:session_id/messages' do
    it 'appends a user message and triggers a reply' do
      expect do
        post "/addons/echo/projects/#{@project.id}/sessions/#{session.id}/messages",
          params: { content: 'What is the impact?' }
      end.to change { session.messages.count }.by(1)
        .and have_enqueued_job(Dradis::Plugins::Echo::ReplyJob)

      expect(response).to have_http_status(:ok)

      message = session.messages.order(:id).last
      expect(message.role).to eq('user')
      expect(message.user).to eq(user)
      expect(message.content).to eq('What is the impact?')
    end

    it 'rejects a blank message without enqueuing a reply' do
      # params.expect(:content) treats a blank required scalar as missing and
      # raises ParameterMissing (a 400 in production, before the reply gate is
      # ever reached) rather than persisting an invalid message.
      expect do
        post "/addons/echo/projects/#{@project.id}/sessions/#{session.id}/messages",
          params: { content: '' }
      end.to raise_error(ActionController::ParameterMissing)

      expect(session.messages.count).to eq(0)
    end

    it 'denies a session whose record is outside the current project scope' do
      other_session = create(:echo_session, agent: agent, record: create(:issue, node: create(:node)))

      expect do
        post "/addons/echo/projects/#{@project.id}/sessions/#{other_session.id}/messages",
          params: { content: 'Hello' }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
