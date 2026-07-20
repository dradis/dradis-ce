require 'rails_helper'

describe 'Roslin widget' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: @project.issue_library) }

  describe 'GET /projects/:project_id/issues/:id' do
    context 'when Roslin is enabled' do
      before do
        roslin_agent = instance_double(Dradis::Plugins::Echo::Agent, enabled?: true)
        allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:instance).and_return(roslin_agent)
        allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:language_tool_configured?).and_return(true)
        allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:language_tool_reachable?).and_return(true)
      end

      it 'renders the status icons and collapsed widget body' do
        get "/projects/#{@project.id}/issues/#{issue.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('data-behavior="roslin-status-success"')
        expect(response.body).to include('data-behavior="roslin-status-error"')
        expect(response.body).to include('data-behavior="roslin-issues-summary"')
        expect(response.body).to match(/<div id="roslin-widget" class="collapse"/)
      end
    end

    context 'when Roslin is disabled' do
      before do
        roslin_agent = instance_double(Dradis::Plugins::Echo::Agent, enabled?: false)
        allow(Dradis::Plugins::Echo::Agents::Roslin).to receive(:instance).and_return(roslin_agent)
      end

      it 'renders the info icon and enable prompt' do
        get "/projects/#{@project.id}/issues/#{issue.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('fa-info-circle')
        expect(response.body).to include(Dradis::Plugins::Echo::Engine.routes.url_helpers.agents_path)
        expect(response.body).to match(/<div id="roslin-widget" class="collapse show"/)
      end
    end

  end
end
