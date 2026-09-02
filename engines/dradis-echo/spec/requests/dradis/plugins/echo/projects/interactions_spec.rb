require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# Regression: the Echo tab loads interactions#index into a native
# <turbo-frame id="echo_issue_<id>">, and the "+ New" link navigates that same
# frame back. If index answers frameless, Turbo reports "Content missing", so the
# index response must carry the record's Echo frame verbatim.
describe 'Echo interactions' do
  before { login_to_project_as_user }

  let!(:roslin) do
    Dradis::Plugins::Echo::Agents::Roslin.provision!.tap { |agent| agent.update!(enabled: true) }
  end

  let(:issue) do
    create(:issue, node: @project.issue_library, text: "#[Title]#\nSQLi")
  end

  describe 'GET /addons/echo/projects/:project_id/interactions' do
    it 'renders the sessions panel entry point' do
      get "/addons/echo/projects/#{@project.id}/interactions", params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Start a new conversation')
    end

    it 'wraps the conversation list in the record Echo turbo-frame' do
      get "/addons/echo/projects/#{@project.id}/interactions",
        params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        "<turbo-frame id=\"#{ActionView::RecordIdentifier.dom_id(issue, :echo)}\""
      )
    end

    it 'matches the frame id the session show "+ New" link navigates' do
      # The "+ New" link and the index share dom_id(record, :echo); prove they
      # agree so a Turbo navigation frame-matches instead of erroring out.
      session = create(:echo_session, agent: roslin, record: issue)

      get "/addons/echo/projects/#{@project.id}/sessions/#{session.id}",
        params: { type: 'issue', record: issue.id }
      frame_id = ActionView::RecordIdentifier.dom_id(issue, :echo)
      new_conversation_link = echo.project_interactions_path(@project, type: 'issue', record: issue.id)
      expect(response.body).to include("<turbo-frame id=\"#{frame_id}\"")
      # href attributes HTML-escape the query separator (& -> &amp;); match escaped.
      expect(response.body).to include(ERB::Util.html_escape(new_conversation_link))
    end

    it 'raises RecordNotFound (404) rather than a 500 for a missing or unknown type' do
      expect do
        get "/addons/echo/projects/#{@project.id}/interactions", params: { record: issue.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET /addons/echo/projects/:project_id/interactions/:id/preview' do
    it 'renders the prompt with its liquid drops resolved' do
      prompt = @logged_in_as.prompts.create!(
        title: 'Summary', prompt: 'Issue: {{ issue.title }}', scope: 'issue', visibility: :user
      )

      get "/addons/echo/projects/#{@project.id}/interactions/#{prompt.id}/preview",
        params: { type: 'issue', record: issue.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Issue: SQLi')
    end

    it 'raises a clear error for a whitelisted scope with no drop mapping' do
      stub_const('Dradis::Plugins::Echo::Prompt::SCOPES', %i[issue note])
      note = create(:note, node: @project.issue_library)
      prompt = @logged_in_as.prompts.create!(
        title: 'Note prompt', prompt: 'Draft it', scope: 'issue', visibility: :user
      )
      prompt.update_column(:scope, 'note')

      expect do
        get "/addons/echo/projects/#{@project.id}/interactions/#{prompt.id}/preview",
          params: { type: 'note', record: note.id }
      end.to raise_error(ArgumentError, /note/i)
    end
  end

  describe 'the retired Roslin one-shot path' do
    it 'no longer exposes a create route' do
      expect do
        post "/addons/echo/projects/#{@project.id}/interactions", params: { type: 'issue', record: issue.id }
      end.to raise_error(ActionController::RoutingError)
    end

    it 'no longer exposes a show route' do
      expect do
        get "/addons/echo/projects/#{@project.id}/interactions/1", params: { type: 'issue', record: issue.id }
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
