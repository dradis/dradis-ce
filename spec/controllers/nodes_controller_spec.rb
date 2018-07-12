require 'rails_helper'

RSpec.describe NodesController do
  include ProControllerMacros

  before { login_as_user }

  before do
    @project = create(:project)
    @project.authors << @logged_in_as
    @project.save!
    @other_project = create(:project)
    @other_project.authors << @logged_in_as
    @other_project.save!
  end

  let(:node) { create(:node, project: @project) }

  describe 'GET #show' do
    example "when project ID doesn't match node.project_id" do
      expect do
        get :show, params: { project_id: @other_project.id, id: node.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    example 'normal functionality' do
      get :show, params: { project_id: @project.id, id: node.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #edit' do
    example "when project ID doesn't match node.project_id" do
      expect do
        get :edit, params: { project_id: @other_project.id, id: node.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    example 'normal functionality' do
      get :edit, params: { project_id: @project.id, id: node.id }
      expect(response).to have_http_status(200)
    end
  end

  # If we want to be super-thorough we should also test #update, #create
  # etc. in the same way but it's not worth it for now
end
