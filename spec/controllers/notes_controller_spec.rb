require 'rails_helper'

describe NotesController, type: :controller do
  let(:current_user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:node) { create(:node, project: @project) }
  let(:note) { create(:note, node: node) }

  let(:edit_params)   { { project_id: @project.id, node_id: node.id, id: note.id } }
  let(:lock_params)   { { project_id: @project.id, node_id: node.id, id: note.id } }
  let(:unlock_params) { { project_id: @project.id, node_id: node.id, id: note.id } }
  let(:record) { note }

  before do
    @project = create(:project)
    login_as_user(current_user)
  end

  it_behaves_like 'editing lock behavior'
end
