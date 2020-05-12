require 'rails_helper'

describe 'upload pages' do
  before { login_to_project_as_user }

  describe 'state selection', js: true do
    before do
      visit project_upload_manager_path(current_project)
    end

    it 'is disabled when choosing the dradis package/template' do
      find('#uploader').find(:option, 'Dradis Package').select_option
      expect(find('#state:disabled')).to_not be nil

      find('#uploader').find(:option, 'Dradis Template').select_option
      expect(find('#state:disabled')).to_not be nil
    end
  end
end
