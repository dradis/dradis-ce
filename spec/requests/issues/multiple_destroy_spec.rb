require 'rails_helper'

describe 'DELETE /projects/:project_id/issues/multiple_destroy', type: :request do
  before { login_to_project_as_user }

  let(:path) { multiple_destroy_project_issues_path(current_project) }
  let(:ids) { [create(:issue, node: current_project.issue_library).id] }

  it_behaves_like 'a multiple_destroy json response'
end
