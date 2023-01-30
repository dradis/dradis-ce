require 'rails_helper'

describe 'Setup::Analytics' do
  include ConfigurationMacros

  context 'when analytics configuration has not been set' do
    before do
      visit new_setup_analytics_path
    end

    it 'creates a configuration entry with value true when a user opts-in' do
      expect do
        click_button('Share statistics with us!')
      end.to change { Configuration.count }.by(1)
      expect(Configuration.last).to have_attributes(name: 'admin:analytics', value: 'true')
    end

    it 'creates a configuration entry with value of false when a user does not opt-in' do
      expect do
        click_button('No thanks')
      end.to change { Configuration.count }.by(1)
      expect(Configuration.last).to have_attributes(name: 'admin:analytics', value: 'false')
    end
  end

  context 'when analytics configuration has already been set' do
    it 'redirects to the user\'s project' do
      login_to_project_as_user
      create_configuration('admin:analytics', 'true')
      visit new_setup_analytics_path
      expect(current_path).to eq(project_path(1))
    end
  end
end
