require 'rails_helper'

describe Dradis::Plugins::Echo::Provider::HttpStreaming do
  let(:provider) do
    Dradis::Plugins::Echo::Provider::Anthropic.new(
      address: 'https://api.anthropic.com/v1/messages',
      api_key: 'sk-ant-test',
      model: 'claude-sonnet-4-6',
      name: 'Test'
    )
  end

  def stub_http(body:, code: '200')
    response = instance_double(Net::HTTPResponse, code: code, body: body)
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(code == '200')
    allow(response).to receive(:read_body).and_yield(body)

    http = instance_double(Net::HTTP)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)
    allow(http).to receive(:write_timeout=)
    allow(http).to receive(:request).and_yield(response)
    allow(Net::HTTP).to receive(:new).and_return(http)
  end

  describe '#parse_sse_response' do
    it 'raises an error for non-2xx responses' do
      stub_http(body: 'Unauthorized', code: '401')
      expect do
        provider.send(:parse_sse_response,
                      URI('https://api.anthropic.com/v1/messages'),
                      headers: {},
                      body: {})
      end.to raise_error(RuntimeError, /API error \(401\)/)
    end

    it 'parses SSE lines and yields text chunks' do
      delta_event = { 'type' => 'content_block_delta', 'delta' => { 'type' => 'text_delta', 'text' => 'Hi' } }
      sse_body = "data: #{JSON.generate(delta_event)}\n\n"
      stub_http(body: sse_body)

      chunks = []
      provider.send(:parse_sse_response,
                    URI('https://api.anthropic.com/v1/messages'),
                    headers: {},
                    body: {}) { |chunk| chunks << chunk }

      expect(chunks).to eq(['Hi'])
    end

    it 'skips non-data lines' do
      sse_body = "event: message_start\ndata: {\"type\":\"message_start\"}\n\n"
      stub_http(body: sse_body)

      chunks = []
      provider.send(:parse_sse_response,
                    URI('https://api.anthropic.com/v1/messages'),
                    headers: {},
                    body: {}) { |chunk| chunks << chunk }

      expect(chunks).to be_empty
    end

    it 'skips malformed JSON lines without raising' do
      sse_body = "data: not-valid-json\ndata: {\"type\":\"message_start\"}\n\n"
      stub_http(body: sse_body)

      expect do
        provider.send(:parse_sse_response,
                      URI('https://api.anthropic.com/v1/messages'),
                      headers: {},
                      body: {}) { |_chunk| }
      end.not_to raise_error
    end
  end

  describe '#generate' do
    it 'accumulates chunks and returns the full string when called without a block' do
      delta_event = { 'type' => 'content_block_delta', 'delta' => { 'type' => 'text_delta', 'text' => 'Hello' } }
      sse_body = "data: #{JSON.generate(delta_event)}\n\n"
      stub_http(body: sse_body)

      result = provider.generate(prompt: 'test')
      expect(result).to eq('Hello')
    end

    it 'yields each chunk and returns nil when called with a block' do
      delta_event = { 'type' => 'content_block_delta', 'delta' => { 'type' => 'text_delta', 'text' => 'Hello' } }
      sse_body = "data: #{JSON.generate(delta_event)}\n\n"
      stub_http(body: sse_body)

      chunks = []
      result = provider.generate(prompt: 'test') { |chunk| chunks << chunk }
      expect(chunks).to eq(['Hello'])
      expect(result).to be_nil
    end
  end
end
