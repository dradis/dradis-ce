require 'rails_helper'

describe 'console requests' do
  before { login_as_user }

  describe 'GET #status' do
    it 'keeps polling while the job is still writing lines' do
      logger = Log.new.write('Importing...')

      get status_console_index_path, params: { item_id: logger.uid, format: :js }, xhr: true

      expect(response.body).to include('var working = true;')
    end

    it 'stops polling once the job has failed' do
      logger = Log.new
      logger.fail!

      get status_console_index_path, params: { item_id: logger.uid, format: :js }, xhr: true

      expect(response.body).to include('var working = false;')
    end
  end
end
