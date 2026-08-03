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

  describe 'POST /addons/echo/projects/:project_id/sessions' do
    let(:params) do
      { type: 'issue', record: issue.id, prompt_id: prompt.id, prompt: 'Summarise the SQLi finding' }
    end

    it 'creates a session with the first user message but defers the reply to the subscribed client' do
      expect do
        post "/addons/echo/projects/#{@project.id}/sessions", params: params
      end.to change(Dradis::Plugins::Echo::Session, :count).by(1)
        .and change(Dradis::Plugins::Echo::Message, :count).by(1)

      # The reply is triggered by the session Stimulus controller once subscribed,
      # not by create — otherwise the streaming container broadcasts before the
      # socket is listening and never renders live.
      expect(Dradis::Plugins::Echo::ReplyJob).not_to have_been_enqueued

      session = Dradis::Plugins::Echo::Session.last
      expect(session.title).to eq(prompt.title)
      expect(session.user).to eq(user)
      expect(session.record).to eq(issue)
      expect(session).to be_reply_pending

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

    it 'returns 422 for a blank prompt instead of raising a 500' do
      expect do
        post "/addons/echo/projects/#{@project.id}/sessions",
          params: params.merge(prompt: '')
      end.not_to change(Dradis::Plugins::Echo::Session, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'honours the Prompt::SCOPES whitelist' do
      expect do
        post "/addons/echo/projects/#{@project.id}/sessions",
          params: params.merge(type: 'node')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'denies a record outside the current project scope' do
      other_issue = create(:issue, node: create(:node))

      expect do
        post "/addons/echo/projects/#{@project.id}/sessions",
          params: params.merge(record: other_issue.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET /addons/echo/projects/:project_id/sessions/:id' do
    # The initial Send-button lock is server-rendered off generating? OR
    # reply_pending?, so a freshly-created (idle, reply-owed) session comes back
    # disabled without depending on the composer_state broadcast that races the
    # client's subscribe. That race can't be reproduced in rack_test, so we assert
    # the server-rendered invariant.
    def composer_state
      Nokogiri::HTML(response.body).at_css('[data-behavior="echo-composer-state"]')
    end

    def send_button
      composer_state.at_css('button[type="submit"]')
    end

    it 'server-renders the Send button disabled for a reply_pending session' do
      session = create(:echo_session, record: issue, user: user, status: :idle)
      create(:echo_message, session: session, role: :user, user: user)
      expect(session).to be_reply_pending

      get "/addons/echo/projects/#{@project.id}/sessions/#{session.id}"

      expect(response).to have_http_status(:ok)
      expect(composer_state['data-generating']).to eq('true')
      expect(send_button.attributes).to have_key('disabled')
    end

    it 'server-renders the Send button disabled for a generating session' do
      session = create(:echo_session, record: issue, user: user, status: :generating)
      create(:echo_message, session: session, role: :user, user: user)

      get "/addons/echo/projects/#{@project.id}/sessions/#{session.id}"

      expect(response).to have_http_status(:ok)
      expect(composer_state['data-generating']).to eq('true')
      expect(send_button.attributes).to have_key('disabled')
    end

    it 'server-renders the Send button enabled for an answered session' do
      session = create(:echo_session, record: issue, user: user, status: :idle)
      create(:echo_message, session: session, role: :user, user: user)
      create(:assistant_message, session: session)
      expect(session).not_to be_reply_pending

      get "/addons/echo/projects/#{@project.id}/sessions/#{session.id}"

      expect(response).to have_http_status(:ok)
      expect(composer_state['data-generating']).to eq('false')
      expect(send_button.attributes).not_to have_key('disabled')
    end
  end
end
