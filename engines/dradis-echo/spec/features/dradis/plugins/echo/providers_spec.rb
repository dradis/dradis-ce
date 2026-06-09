require 'rails_helper'
require File.expand_path('../../../../factories/providers', __dir__)

describe 'Echo Providers', js: true do
  before { login_as_user }

  describe 'index page' do
    it 'lists existing providers' do
      provider = create(:provider)
      visit echo.providers_path
      expect(page).to have_content(provider.name)
    end
  end

  describe 'creating a provider' do
    it 'adds a new provider' do
      visit echo.new_provider_path
      fill_in 'Name', with: 'My Ollama'
      fill_in 'API Base URL', with: 'http://localhost:11434'
      fill_in 'Model', with: 'qwen2.5:14b'
      click_button 'Add Provider'
      expect(page).to have_content('My Ollama added.')
    end

    it 'shows errors for invalid input' do
      visit echo.new_provider_path
      fill_in 'Name', with: ' '
      fill_in 'API Base URL', with: 'http://localhost:11434'
      fill_in 'Model', with: 'qwen2.5:14b'
      click_button 'Add Provider'
      expect(page).to have_content("can't be blank")
    end
  end

  describe 'editing a provider' do
    let(:provider) { create(:provider) }

    it 'updates the provider' do
      visit echo.edit_provider_path(provider)
      fill_in 'Name', with: 'Updated Name'
      click_button 'Update Provider'
      expect(page).to have_content('Updated Name updated.')
    end

    it 'shows errors for invalid input' do
      visit echo.edit_provider_path(provider)
      fill_in 'Name', with: ' '
      click_button 'Update Provider'
      expect(page).to have_content("can't be blank")
    end
  end

  describe 'deleting a provider' do
    it 'removes the provider' do
      provider = create(:provider, name: 'Deletable')
      visit echo.providers_path
      within('.provider-row', text: 'Deletable') do
        click_button 'Delete'
      end
      expect(page).to have_content('Deletable removed.')
    end
  end
end
