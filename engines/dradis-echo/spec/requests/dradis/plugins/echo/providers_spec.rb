require 'rails_helper'

describe 'Echo Providers' do
  before { login_as_user }

  let(:provider) { create(:provider) }

  describe 'GET /addons/echo/providers' do
    it 'returns a list of providers' do
      provider
      get echo.providers_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /addons/echo/providers/new' do
    it 'renders the new provider form' do
      get echo.new_provider_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /addons/echo/providers' do
    context 'with valid params' do
      let(:valid_params) do
        { provider: { name: 'My Ollama', type: 'Ollama', address: 'http://localhost:11434', model: 'qwen2.5:14b' } }
      end

      it 'creates a provider' do
        expect {
          post echo.providers_path, params: valid_params
        }.to change(Dradis::Plugins::Echo::Provider, :count).by(1)
      end

      it 'redirects to the providers list' do
        post echo.providers_path, params: valid_params
        expect(response).to redirect_to(echo.providers_path)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { provider: { name: '', type: 'Ollama', address: 'http://localhost:11434', model: 'qwen2.5:14b' } }
      end

      it 'does not create a provider' do
        expect {
          post echo.providers_path, params: invalid_params
        }.not_to change(Dradis::Plugins::Echo::Provider, :count)
      end

      it 'renders the new form with errors' do
        post echo.providers_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /addons/echo/providers/:id/edit' do
    it 'renders the edit form' do
      get echo.edit_provider_path(provider)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /addons/echo/providers/:id' do
    context 'with valid params' do
      it 'updates the provider' do
        patch echo.provider_path(provider), params: { provider: { name: 'Updated Name' } }
        expect(provider.reload.name).to eq('Updated Name')
      end

      it 'redirects to the providers list' do
        patch echo.provider_path(provider), params: { provider: { name: 'Updated Name' } }
        expect(response).to redirect_to(echo.providers_path)
      end
    end

    context 'with invalid params' do
      it 'renders the edit form with errors' do
        patch echo.provider_path(provider), params: { provider: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when api_key is blank' do
      it 'does not overwrite an existing api_key' do
        anthropic = create(:anthropic_provider)
        patch echo.provider_path(anthropic), params: { provider: { name: anthropic.name, api_key: '' } }
        expect(anthropic.reload.api_key).to be_present
      end
    end
  end

  describe 'DELETE /addons/echo/providers/:id' do
    context 'when the provider is not in use' do
      it 'destroys the provider' do
        provider
        expect {
          delete echo.provider_path(provider)
        }.to change(Dradis::Plugins::Echo::Provider, :count).by(-1)
      end

      it 'redirects to the providers list' do
        delete echo.provider_path(provider)
        expect(response).to redirect_to(echo.providers_path)
      end
    end

    context 'when the provider is in use' do
      before do
        allow(provider).to receive(:in_use?).and_return(true)
        allow(Dradis::Plugins::Echo::Provider).to receive(:find).and_return(provider)
      end

      it 'does not destroy the provider' do
        expect {
          delete echo.provider_path(provider)
        }.not_to change(Dradis::Plugins::Echo::Provider, :count)
      end

      it 'redirects with an alert' do
        delete echo.provider_path(provider)
        expect(response).to redirect_to(echo.providers_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
