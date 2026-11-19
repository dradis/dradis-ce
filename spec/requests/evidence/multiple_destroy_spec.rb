require 'rails_helper'

describe 'DELETE /projects/:project_id/nodes/:node_id/evidence/multiple_destroy', type: :request do
  before { login_to_project_as_user }

  let(:node) { create(:node) }
  let(:issue) { create(:issue, node: current_project.issue_library) }
  let(:path) { multiple_destroy_project_node_evidence_index_path(current_project, node) }
  let(:ids) { [create(:evidence, node: node, issue: issue).id] }

  it_behaves_like 'a multiple_destroy json response'
end
