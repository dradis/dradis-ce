require 'rails_helper'

describe IssuesController, type: :controller do
  let(:current_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:issue) { create(:issue, project: @project) }

  let(:edit_params)   { { project_id: @project.id, id: issue.id } }
  let(:lock_params)   { { project_id: @project.id, id: issue.id } }
  let(:unlock_params) { { project_id: @project.id, id: issue.id } }
  let(:record) { issue }

  before do
    @project = create(:project)
    login_as_user(current_user)
  end

  it_behaves_like 'editing lock behavior'
end
