require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider::Ollama do
  subject(:provider) { build(:provider) }

  let(:client) { instance_double(::Ollama::Controllers::Client) }

  before do
    allow(provider).to receive(:client).and_return(client)
  end

  def stub_events(*events)
    allow(client).to receive(:generate) do |_payload, &block|
      events.each { |event| block.call(event, nil) }
    end
  end

  describe '#generate' do
    it 'concatenates response chunks into the buffer' do
      stub_events(
        { 'response' => 'Hello ', 'done' => false },
        { 'response' => 'world', 'done' => false },
        { 'response' => '', 'done' => true }
      )

      expect(provider.generate(prompt: 'hi')).to eq('Hello world')
    end

    it 'preserves whitespace-only chunks, such as standalone line breaks' do
      stub_events(
        { 'response' => '1. First item.', 'done' => false },
        { 'response' => "  \n", 'done' => false },
        { 'response' => '2. Second item.', 'done' => false },
        { 'response' => '', 'done' => true }
      )

      expect(provider.generate(prompt: 'hi')).to eq("1. First item.  \n2. Second item.")
    end

    it 'skips events with an empty response, such as thinking-only chunks' do
      stub_events(
        { 'response' => '', 'thinking' => 'Reasoning...', 'done' => false },
        { 'response' => 'Answer', 'done' => false },
        { 'response' => '', 'done' => true }
      )

      expect(provider.generate(prompt: 'hi')).to eq('Answer')
    end

    it 'replaces think tags embedded in the response text' do
      stub_events(
        { 'response' => '<think>', 'done' => false },
        { 'response' => 'reasoning', 'done' => false },
        { 'response' => '</think>', 'done' => false },
        { 'response' => 'Answer', 'done' => false },
        { 'response' => '', 'done' => true }
      )

      expect(provider.generate(prompt: 'hi')).to eq('{thinking}reasoning{/thinking}Answer')
    end

    it 'yields each chunk to the given block instead of buffering' do
      stub_events(
        { 'response' => 'Hello ', 'done' => false },
        { 'response' => 'world', 'done' => false },
        { 'response' => '', 'done' => true }
      )

      chunks = []
      provider.generate(prompt: 'hi') { |chunk| chunks << chunk }

      expect(chunks).to eq(['Hello ', 'world'])
    end
  end
end
