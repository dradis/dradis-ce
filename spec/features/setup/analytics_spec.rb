require 'rails_helper'

describe 'Setup::Analytics' do

  context "when analytics configuration has not been set" do
    before do
      visit new_setup_analytics_path
    end

    it "creates a configuration entry with value true when a user opts-in" do
      click_button('Share statistics with us!')
      expect(Configuration.last).to have_attributes(name: 'admin:analytics', value: 'true')
    end

    it "creates a configuration entry with value of false when a user does not opt-in" do
      click_button('No thanks')
      expect(Configuration.last).to have_attributes(name: 'admin:analytics', value: 'false')
    end
  end

  context "when analytics configuration has already been set" do
    it 'redirects to the user\'s project' do
      login_to_project_as_user
      configuration = create(:configuration, name: 'admin:analytics', value: 'true')
      visit new_setup_analytics_path
      expect(current_path).to eq(project_path(1)) 
    end
  end
end
