require 'rails_helper'

describe 'console requests' do
  before { login_as_user }

  describe 'GET #status' do
    it 'keeps polling while the job is still writing lines' do
      logger = Log.new.write('Importing...')

      get status_console_index_path, params: { item_id: logger.uid, format: :js }, xhr: true

      expect(response.body).to include('var working = true;')
    end

    it 'stops polling when a line is written after the final line' do
      logger = Log.new
      logger.complete!
      logger.write('Job id is 123.')

      get status_console_index_path, params: { item_id: logger.uid, format: :js }, xhr: true

      expect(response.body).to include('var working = false;')
      expect(response.body).to include('ConsoleUpdater.failed = false;')
    end

    it 'stops polling and flags the job as failed once the job has failed' do
      logger = Log.new
      logger.fail!

      get status_console_index_path, params: { item_id: logger.uid, format: :js }, xhr: true

      expect(response.body).to include('var working = false;')
      expect(response.body).to include('ConsoleUpdater.failed = true;')
    end
  end
end
