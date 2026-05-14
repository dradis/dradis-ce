require 'rails_helper'

describe 'static_pages' do
  before { skip 'CE only' if defined?(Dradis::Pro) }
  before { login_to_project_as_user }

  describe 'GET /projects/1/addons/gateway' do
    it 'renders successfully with an empty project' do
      get static_gateway_path
      expect(response).to have_http_status(:ok)
    end

    context 'with issues and nodes' do
      let(:project)  { Project.new }
      let(:issuelib) { project.issue_library }
      let(:node)     { create(:node) }

      before do
        issue = create(:issue, node: issuelib)
        create(:evidence, node: node, issue: issue)
      end

      it 'renders successfully' do
        get static_gateway_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
