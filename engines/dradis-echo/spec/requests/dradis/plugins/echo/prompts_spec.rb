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

  describe 'GET /addons/echo/prompts/new' do
    it 'keeps the icon on each icon option' do
      get '/addons/echo/prompts/new', params: { scope: 'issue' }

      icons = Nokogiri::HTML(response.body).css('#prompt_icon option').map { |option| option['data-combobox-option-icon'] }
      expect(icons).not_to be_empty
      expect(icons).to all(start_with('fa-solid fa-'))
    end
  end

  describe 'PATCH /addons/echo/prompts/:id' do
    let(:prompt) { @logged_in_as.prompts.create!(prompt: 'Summarize this', scope: 'issue', title: 'Summary') }

    context 'without a title' do
      before { patch "/addons/echo/prompts/#{prompt.id}", params: { prompt: { title: '' } } }

      it 'keeps the saved title and shows the error next to the title field' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(prompt.reload.title).to eq('Summary')

        errors = Nokogiri::HTML(response.body).css('.invalid-feedback').map { |error| error.text.strip }
        expect(errors).to include("Title can't be blank")
      end
    end
  end
end
