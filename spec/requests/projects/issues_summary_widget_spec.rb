require 'rails_helper'

describe 'Projects', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:id' do
    it 'renders the issues summary frame' do
      get project_path(current_project)

      expect(response.body).to include('Issues so far')
      expect(response.body).to include('<turbo-frame id="issues-summary"')
    end
  end
end
