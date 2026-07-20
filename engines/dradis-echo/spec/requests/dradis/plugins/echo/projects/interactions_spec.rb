require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo interactions' do
  let(:user) { create(:user) }

  before do
    login_as_user(user)
    @project = Project.new
  end

  let!(:roslin) do
    Dradis::Plugins::Echo::Agents::Roslin.provision!.tap { |agent| agent.update!(enabled: true) }
  end

  let!(:prompt) do
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

  describe 'GET /addons/echo/projects/:project_id/interactions' do
    it 'renders the section heading using the app heading convention' do
      get "/addons/echo/projects/#{@project.id}/interactions",
        params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<h5 class="mb-3">Conversations</h5>')
      expect(response.body).to include('<h5 class="mb-3">Start a new conversation</h5>')
      expect(response.body).not_to include('echo-section-label')
    end

    it 'renders an existing conversation via the shared session-item partial' do
      session = create(:echo_session, record: issue, user: user)

      get "/addons/echo/projects/#{@project.id}/interactions",
        params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(id="#{ActionView::RecordIdentifier.dom_id(session)}"))
      expect(response.body).to include('class="echo-session-item"')
    end

    it 'renders the conversations list and prompt picker as two columns' do
      get "/addons/echo/projects/#{@project.id}/interactions",
        params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('echo-interactions-layout')
      expect(response.body).to include('echo-interactions-conversations')
      expect(response.body).to include('echo-interactions-prompts')
    end
  end
end
