require 'rails_helper'

RSpec.describe NotesController do
  include ProControllerMacros

  before { login_as_user }

  before do
    @project = create(:project)
    @project.authors << @logged_in_as
    @project.save!
  end

  # If you don't do this, note creation fails because vesion creation fails
  # info_for_paper_trail isn't set properly in the controller. Turning off
  # PaperTrail is the lazy option but PT is irrelevant to what I'm trying to
  # test for here so I don't think it matters.
  before { PaperTrail.enabled = false }
  after { PaperTrail.enabled = true }

  let(:other_project) do
    op = create(:project)
    op.authors << @logged_in_as
    op.save!
    op
  end

  let(:node) { create(:node, project: @project) }
  let(:note) { create(:note, node: node) }

  let(:other_node) { create(:node, project: @project) }

  describe 'GET #show' do
    let(:params) { { project_id: @project.id, node_id: node.id, id: note.id } }

    example 'normal functionality' do
      get :show, params: params
      expect(response).to have_http_status(200)
    end

    example 'wrong project ID' do
      expect do
        get :show, params: params.merge(project_id: other_project.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    example 'wrong node ID' do
      expect do
        get :show, params: params.merge(node_id: other_node.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
