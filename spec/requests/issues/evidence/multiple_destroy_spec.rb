require 'rails_helper'

describe 'DELETE /projects/:project_id/issues/:issue_id/evidence/multiple_destroy', type: :request do
  before { login_to_project_as_user }

  let(:node) { create(:node) }
  let(:issue) { create(:issue, node: current_project.issue_library) }
  let(:path) { multiple_destroy_project_issue_evidence_index_path(current_project, issue) }
  let(:ids) { [create(:evidence, node: node, issue: issue).id] }

  it_behaves_like 'a multiple_destroy json response'
end
