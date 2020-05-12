require 'rails_helper'

describe 'upload pages' do
  before { login_to_project_as_user }

  describe 'state selection', js: true do
    before do
      visit project_upload_manager_path(current_project)
    end

    it 'is disabled when choosing the dradis package/template' do
      find('#uploader').find(:option, 'Dradis Package').select_option
      expect(page).to have_css('#state:disabled')

      find('#uploader').find(:option, 'Dradis Template').select_option
      expect(page).to have_css('#state:disabled')
    end
  end
end
