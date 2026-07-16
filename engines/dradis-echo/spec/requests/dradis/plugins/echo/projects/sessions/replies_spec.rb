require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo session replies' do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  before do
    login_as_user(user)
    @project = Project.new
  end

  let(:agent) { create(:agent, enabled: true) }
  let(:issue) { create(:issue, node: @project.issue_library, text: "#[Title]#\nSQLi") }
  let(:session) { create(:echo_session, agent: agent, record: issue) }

  describe 'POST /addons/echo/projects/:project_id/sessions/:session_id/reply' do
    it 'enqueues a reply when one is pending (the newest message is a user turn)' do
      create(:echo_message, session: session, role: :user, content: 'What is the impact?', user: user)

      expect {
        post "/addons/echo/projects/#{@project.id}/sessions/#{session.id}/reply"
      }.to have_enqueued_job(Dradis::Plugins::Echo::ReplyJob).with(session)

      expect(response).to have_http_status(:ok)
    end

    it 'does not enqueue a reply once the session has already been answered' do
      create(:echo_message, session: session, role: :user, content: 'What is the impact?', user: user)
      create(:assistant_message, session: session, content: 'It is high.')

      expect {
        post "/addons/echo/projects/#{@project.id}/sessions/#{session.id}/reply"
      }.not_to have_enqueued_job(Dradis::Plugins::Echo::ReplyJob)

      expect(response).to have_http_status(:ok)
    end

    it 'denies a session whose record is outside the current project scope' do
      other_session = create(:echo_session, agent: agent, record: create(:issue, node: create(:node)))

      expect {
        post "/addons/echo/projects/#{@project.id}/sessions/#{other_session.id}/reply"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
