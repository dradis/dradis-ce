require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider::Anthropic do
  let(:provider) do
    described_class.new(
      address: described_class::DEFAULT_ADDRESS,
      api_key: 'sk-ant-test',
      model: 'claude-sonnet-4-6',
      name: 'Test'
    )
  end

  describe '#build_uri' do
    it 'returns the configured address' do
      expect(provider.send(:build_uri, 'claude-sonnet-4-6').to_s).to eq(described_class::DEFAULT_ADDRESS)
    end

    it 'uses a custom address when set' do
      provider.address = 'https://anthropic.proxy.example.com/v1/messages'
      expect(provider.send(:build_uri, 'claude-sonnet-4-6').to_s)
        .to eq('https://anthropic.proxy.example.com/v1/messages')
    end
  end

  describe '#build_headers' do
    it 'includes the API key' do
      expect(provider.send(:build_headers)['x-api-key']).to eq('sk-ant-test')
    end

    it 'includes the API version' do
      expect(provider.send(:build_headers)['anthropic-version']).to eq(described_class::API_VERSION)
    end
  end

  describe '#build_body' do
    it 'builds a streaming messages request' do
      body = provider.send(:build_body, prompt: 'Hello', model: 'claude-sonnet-4-6')
      expect(body[:model]).to eq('claude-sonnet-4-6')
      expect(body[:messages]).to eq([{ role: 'user', content: 'Hello' }])
      expect(body[:stream]).to be true
      expect(body[:max_tokens]).to eq(described_class::DEFAULT_MAX_TOKENS)
    end
  end

  describe '#extract_text' do
    it 'extracts text from content_block_delta events' do
      payload = {
        'type'  => 'content_block_delta',
        'delta' => { 'type' => 'text_delta', 'text' => 'Hello' }
      }
      expect(provider.send(:extract_text, payload)).to eq('Hello')
    end

    it 'returns nil for message_start events' do
      payload = { 'type' => 'message_start', 'message' => {} }
      expect(provider.send(:extract_text, payload)).to be_nil
    end

    it 'returns nil for message_stop events' do
      payload = { 'type' => 'message_stop' }
      expect(provider.send(:extract_text, payload)).to be_nil
    end

    it 'returns nil for content_block_stop events' do
      payload = { 'type' => 'content_block_stop', 'index' => 0 }
      expect(provider.send(:extract_text, payload)).to be_nil
    end
  end
end
