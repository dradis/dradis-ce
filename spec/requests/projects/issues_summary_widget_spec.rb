require 'rails_helper'

describe 'Projects', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:id' do
    it 'renders the issues summary frame' do
      get project_path(current_project)

      expect(response.body).to include('Issues so far')
      expect(response.body).to include('data-behavior="issues-summary"')
      expect(response.body).to include('id="issues-summary"')
    end

    it 'renders the grouping selector, hidden' do
      get project_path(current_project)

      expect(response.body).to include('issues-grouping-select')
    end
  end
end
