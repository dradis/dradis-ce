require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo sessions' do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  before do
    login_as_user(user)
    @project = Project.new
  end

  let!(:roslin) do
    Dradis::Plugins::Echo::Agents::Roslin.provision!.tap { |agent| agent.update!(enabled: true) }
  end

  let(:prompt) do
    user.prompts.create!(
      title: 'Summarise the finding',
      prompt: 'Summarise {{ issue.title }}',
      scope: 'issue',
      visibility: :user
    )
  end

  let(:issue) do
    create(:issue, node: @project.issue_library, text: "#[Title]#\nSQLi")
  end

  describe 'GET /addons/echo/projects/:project_id/sessions' do
    it 'lists the sessions for the record' do
      session = create(:echo_session, agent: roslin, record: issue)

      get "/addons/echo/projects/#{@project.id}/sessions", params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(session.title.to_s) if session.title.present?
    end
  end

  describe 'POST /addons/echo/projects/:project_id/sessions' do
    let(:params) do
      { type: 'issue', record: issue.id, prompt_id: prompt.id, prompt: 'Summarise the SQLi finding' }
    end

    it 'creates a session with the first user message and triggers a reply' do
      expect {
        post "/addons/echo/projects/#{@project.id}/sessions", params: params
      }.to change(Dradis::Plugins::Echo::Session, :count).by(1)
        .and change(Dradis::Plugins::Echo::Message, :count).by(1)
        .and have_enqueued_job(Dradis::Plugins::Echo::ReplyJob)

      session = Dradis::Plugins::Echo::Session.last
      expect(session.title).to eq(prompt.title)
      expect(session.user).to eq(user)
      expect(session.record).to eq(issue)

      message = session.messages.first
      expect(message.role).to eq('user')
      expect(message.content).to eq('Summarise the SQLi finding')
    end

    it 'responds with the session turbo frame' do
      post "/addons/echo/projects/#{@project.id}/sessions", params: params

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("id=\"#{ActionView::RecordIdentifier.dom_id(issue, :echo)}\"")
    end

    it 'copies the title without storing a prompt FK' do
      post "/addons/echo/projects/#{@project.id}/sessions", params: params

      session = Dradis::Plugins::Echo::Session.last
      expect(session.attributes).not_to have_key('prompt_id')
      expect(session.title).to eq(prompt.title)
    end

    it 'honours the Prompt::SCOPES whitelist' do
      expect {
        post "/addons/echo/projects/#{@project.id}/sessions",
          params: params.merge(type: 'node')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'denies a record outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect {
        post "/addons/echo/projects/#{@project.id}/sessions",
          params: params.merge(record: other_issue.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
