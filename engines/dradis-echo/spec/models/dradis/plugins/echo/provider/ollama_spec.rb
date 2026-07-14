require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider::Ollama do
  subject(:provider) { build(:provider) }

  let(:client) { instance_double(::Ollama::Controllers::Client) }

  before do
    allow(provider).to receive(:client).and_return(client)
  end

  def stub_chat(*events)
    allow(client).to receive(:chat) do |_payload, &block|
      events.each { |event| block.call(event, nil) }
    end
  end

  # Ollama's chat endpoint nests each chunk under message.content.
  def content_event(content, done: false)
    { 'message' => { 'content' => content }, 'done' => done }
  end

  describe '#generate' do
    it 'concatenates response chunks into the buffer' do
      stub_chat(
        content_event('Hello '),
        content_event('world'),
        content_event('', done: true)
      )

      expect(provider.generate(prompt: 'hi')).to eq('Hello world')
    end

    it 'preserves whitespace-only chunks, such as standalone line breaks' do
      stub_chat(
        content_event('1. First item.'),
        content_event("  \n"),
        content_event('2. Second item.'),
        content_event('', done: true)
      )

      expect(provider.generate(prompt: 'hi')).to eq("1. First item.  \n2. Second item.")
    end

    it 'skips events with empty content, such as thinking-only chunks' do
      stub_chat(
        { 'message' => { 'content' => '', 'thinking' => 'Reasoning...' }, 'done' => false },
        content_event('Answer'),
        content_event('', done: true)
      )

      expect(provider.generate(prompt: 'hi')).to eq('Answer')
    end

    it 'replaces think tags embedded in the response text' do
      stub_chat(
        content_event('<think>'),
        content_event('reasoning'),
        content_event('</think>'),
        content_event('Answer'),
        content_event('', done: true)
      )

      expect(provider.generate(prompt: 'hi')).to eq('{thinking}reasoning{/thinking}Answer')
    end

    it 'yields each chunk to the given block instead of buffering' do
      stub_chat(
        content_event('Hello '),
        content_event('world'),
        content_event('', done: true)
      )

      chunks = []
      provider.generate(prompt: 'hi') { |chunk| chunks << chunk }

      expect(chunks).to eq(['Hello ', 'world'])
    end

    it 'sends a multi-turn messages array to the chat endpoint' do
      messages = [
        { role: 'user', content: 'Hi' },
        { role: 'assistant', content: 'Hello' },
        { role: 'user', content: 'Again' }
      ]
      expect(client).to receive(:chat)
        .with(hash_including(messages: messages))
        .and_yield(content_event('ok'), nil)

      expect(provider.generate(messages: messages)).to eq('ok')
    end

    it 'wraps the prompt: sugar into a single user message' do
      expect(client).to receive(:chat)
        .with(hash_including(messages: [{ role: 'user', content: 'hi' }]))
        .and_yield(content_event('ok'), nil)

      provider.generate(prompt: 'hi')
    end
  end
end
