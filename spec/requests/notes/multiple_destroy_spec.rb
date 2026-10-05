require 'rails_helper'

describe 'DELETE /projects/:project_id/nodes/:node_id/notes/multiple_destroy', type: :request do
  before { login_to_project_as_user }

  let(:node) { create(:node) }
  let(:path) { multiple_destroy_project_node_notes_path(current_project, node) }
  let(:ids) { [create(:note, node: node).id] }

  it_behaves_like 'a multiple_destroy json response'
end
