require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# Regression coverage for SEC-506 Bug 3: the Echo tab loads interactions#index
# into a native <turbo-frame id="echo_issue_<id>">, and the session's "+ New"
# link navigates that same frame back to interactions#index. If index answers
# frameless, Turbo reports "the response did not contain the expected
# <turbo-frame>" and the tab shows "Content missing". So the index response must
# carry the record's Echo frame verbatim.
describe 'Echo interactions' do
  let(:user) { create(:user) }

  before do
    login_as_user(user)
    @project = Project.new
  end

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
