require 'rails_helper'

RSpec.describe EvidenceController do
  include ControllerMacros

  before { login_as_user }

  before { @project = Project.new }

  # If you don't do this, evidence creation fails because vesion creation fails
  # info_for_paper_trail isn't set properly in the controller. Turning off
  # PaperTrail is the lazy option but PT is irrelevant to what I'm trying to
  # test for here so I don't think it matters.
  before { PaperTrail.enabled = false }
  after { PaperTrail.enabled = true }

  let(:node) { create(:node) }
  let(:evidence) { create(:evidence, node: node) }

  let(:other_node) { create(:node) }

  describe 'GET #show' do
    let(:params) { { project_id: @project.id, node_id: node.id, id: evidence.id } }

    example 'normal functionality' do
      get :show, params: params
      expect(response).to have_http_status(200)
    end

    example 'wrong node ID' do
      expect do
        get :show, params: params.merge(node_id: other_node.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
