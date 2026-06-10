require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider::Gemini do
  let(:provider) do
    described_class.new(
      address: described_class::DEFAULT_ADDRESS,
      api_key: 'AIza-test',
      model: 'gemini-2.0-flash',
      name: 'Test'
    )
  end

  describe '#build_uri' do
    it 'includes the model name and SSE query param' do
      uri = provider.send(:build_uri, 'gemini-2.0-flash')
      expect(uri.to_s).to include('gemini-2.0-flash')
      expect(uri.query).to eq('alt=sse')
    end

    it 'uses a custom address when set' do
      provider.address = 'https://gemini.proxy.example.com/v1beta/models/'
      uri = provider.send(:build_uri, 'gemini-2.0-flash')
      expect(uri.to_s).to include('gemini.proxy.example.com')
      expect(uri.to_s).to include('gemini-2.0-flash')
    end
  end

  describe '#build_headers' do
    it 'includes the API key' do
      expect(provider.send(:build_headers)['x-goog-api-key']).to eq('AIza-test')
    end
  end

  describe '#build_body' do
    it 'wraps the prompt in the Gemini content structure' do
      body = provider.send(:build_body, prompt: 'Hello', model: 'gemini-2.0-flash')
      expect(body[:contents]).to eq([{ role: 'user', parts: [{ text: 'Hello' }] }])
    end
  end

  describe '#extract_text' do
    it 'extracts text from the candidates array' do
      payload = {
        'candidates' => [
          { 'content' => { 'parts' => [{ 'text' => 'Hello' }], 'role' => 'model' } }
        ]
      }
      expect(provider.send(:extract_text, payload)).to eq('Hello')
    end

    it 'returns nil when candidates are empty' do
      expect(provider.send(:extract_text, { 'candidates' => [] })).to be_nil
    end

    it 'returns nil when parts are missing' do
      payload = { 'candidates' => [{ 'content' => {} }] }
      expect(provider.send(:extract_text, payload)).to be_nil
    end
  end
end
