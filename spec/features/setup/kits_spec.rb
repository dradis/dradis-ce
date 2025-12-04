require 'rails_helper'

describe 'Setup::Kits', skip_setup_mock: true do

  context 'when shared password is already set' do
    it 'enqueues a KitImport job if a valid kit is passed' do

      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false

      visit new_setup_kit_path
      expect(page).to have_selector("form[action='#{setup_kit_path(kit: :welcome)}']")

      expect do
        # We'd need JS to be able to click in the link and send a POST
        page.driver.post setup_kit_path(kit: :welcome)
      end.to have_enqueued_job(KitImportJob)
    end

    it 'doesn\'t enque a KitImport if :none is passed' do
      visit new_setup_kit_path
      expect do
        # We'd need JS to be able to click in the link and send a POST
        page.driver.post setup_kit_path(kit: :none)
      end.to_not have_enqueued_job(KitImportJob)
    end

    it 'doesn\'t enque a KitImport if invalid kit is passed' do
      visit new_setup_kit_path
      expect do
        # We'd need JS to be able to click in the link and send a POST
        page.driver.post setup_kit_path(kit: :rspec)
      end.to_not have_enqueued_job(KitImportJob)
    end
  end
end
