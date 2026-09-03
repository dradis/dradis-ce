require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo prompts' do
  before { login_to_project_as_user }

  describe 'GET /addons/echo/prompts' do
    it 'seeds the issue scope defaults for a brand new user' do
      get '/addons/echo/prompts'

      expect(response).to have_http_status(:ok)
      titles = @logged_in_as.prompts.for(:issue).pluck(:title)
      expect(titles).to match_array(Dradis::Plugins::Echo::Prompt.defaults_for(:issue).map(&:title))
    end

    it 'does not duplicate defaults the user already has' do
      get '/addons/echo/prompts'
      get '/addons/echo/prompts'

      titles = @logged_in_as.prompts.for(:issue).pluck(:title)
      expect(titles).to match_array(Dradis::Plugins::Echo::Prompt.defaults_for(:issue).map(&:title))
    end
  end
end
