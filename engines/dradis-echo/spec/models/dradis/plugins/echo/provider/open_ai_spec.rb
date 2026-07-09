require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider::OpenAI do
  let(:provider) do
    described_class.new(
      address: described_class::DEFAULT_ADDRESS,
      api_key: 'sk-test',
      model: 'gpt-4o',
      name: 'Test'
    )
  end

  describe '#build_uri' do
    it 'appends chat/completions to the address' do
      expect(provider.send(:build_uri, 'gpt-4o').to_s)
        .to eq("#{described_class::DEFAULT_ADDRESS}/chat/completions")
    end

    it 'uses a custom address when set' do
      provider.address = 'https://openai.example.com/v1/'
      expect(provider.send(:build_uri, 'gpt-4o').to_s)
        .to include('openai.example.com')
    end
  end

  describe '#build_headers' do
    it 'sends a Bearer token' do
      expect(provider.send(:build_headers)['Authorization']).to eq('Bearer sk-test')
    end
  end

  describe '#build_body' do
    it 'builds a streaming chat completions request' do
      body = provider.send(:build_body, prompt: 'Hello', model: 'gpt-4o')
      expect(body[:model]).to eq('gpt-4o')
      expect(body[:messages]).to eq([{ role: 'user', content: 'Hello' }])
      expect(body[:stream]).to be true
    end
  end

  describe '#extract_text' do
    it 'extracts content from the choices delta' do
      payload = {
        'choices' => [{ 'delta' => { 'content' => 'Hello' }, 'finish_reason' => nil }]
      }
      expect(provider.send(:extract_text, payload)).to eq('Hello')
    end

    it 'returns nil for role-only deltas' do
      payload = {
        'choices' => [{ 'delta' => { 'role' => 'assistant' }, 'finish_reason' => nil }]
      }
      expect(provider.send(:extract_text, payload)).to be_nil
    end

    it 'returns nil for finish deltas' do
      payload = {
        'choices' => [{ 'delta' => {}, 'finish_reason' => 'stop' }]
      }
      expect(provider.send(:extract_text, payload)).to be_nil
    end
  end
end
