require 'rails_helper'
require File.expand_path('../../../../factories/providers', __dir__)
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/sessions', __dir__)
require File.expand_path('../../../../factories/messages', __dir__)

describe Dradis::Plugins::Echo::ReplyJob do
  let(:agent) { create(:agent) }
  let(:session) { create(:echo_session, agent: agent) }

  def stub_stream(*chunks)
    allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
      .to receive(:generate) do |_provider, **_kwargs, &block|
        chunks.each { |chunk| block.call(chunk) }
      end
  end

  def perform
    described_class.perform_now(session)
  end

  before do
    create(:echo_message, session: session, role: :user, content: 'Summarise this issue.')
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow_any_instance_of(Dradis::Plugins::Echo::Session).to receive(:broadcast_composer_state)
  end

  describe 'a successful reply' do
    before { stub_stream('Hello ', 'world') }

    it 'creates an assistant message and persists the streamed text as complete' do
      expect { perform }.to change { session.messages.assistant.count }.by(1)

      message = session.messages.assistant.last
      expect(message).to be_complete
      expect(message.content).to eq('Hello world')
    end

    it 'records model and provider metadata' do
      perform
      metadata = session.messages.assistant.last.metadata

      expect(metadata['model']).to eq(agent.provider.model)
      expect(metadata['provider']).to eq('Ollama')
      expect(metadata['duration_ms']).to be_a(Integer)
    end

    it 'streams each chunk to the message content target' do
      perform
      target = ActionView::RecordIdentifier.dom_id(session.messages.assistant.last, :content)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to)
        .with([session, :messages], target: target, content: 'Hello ')
      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to)
        .with([session, :messages], target: target, content: 'world')
    end

    it 'releases the session back to idle' do
      perform
      expect(session.reload).to be_idle
    end

    it 'broadcasts the composer state when it returns to idle' do
      expect_any_instance_of(Dradis::Plugins::Echo::Session)
        .to receive(:broadcast_composer_state)
      perform
    end
  end

  describe 'stripping reasoning blocks' do
    it "removes Ollama's {thinking} markers from the persisted content" do
      stub_stream('{thinking}I should be brief.{/thinking}', 'The answer is 42.')
      perform
      expect(session.messages.assistant.last.content).to eq('The answer is 42.')
    end

    it 'removes raw <think> blocks' do
      stub_stream('<think>reasoning</think>Final.')
      perform
      content = session.messages.assistant.last.content
      expect(content).to eq('Final.')
      expect(content).not_to include('think')
    end
  end

  describe 'serialising a mid-generation message' do
    before { stub_stream('Answer.') }

    it 're-enqueues itself once when a user message arrived after the cutoff' do
      allow(described_class).to receive(:perform_later)
      # request_reply! has already flipped the session to generating.
      session.update!(status: :generating)

      # Simulate the user speaking again while the reply streamed.
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate) do |_provider, **_kwargs, &block|
          create(:echo_message, session: session, role: :user, content: 'And again?')
          block.call('Answer.')
        end

      perform

      expect(described_class).to have_received(:perform_later).with(session).once
      # Stays generating (no idle flip) so the re-enqueued job keeps the lock.
      expect(session.reload).to be_generating
    end
  end

  describe 'when the agent is not enabled' do
    before { agent.update!(enabled: false) }

    it 'raises so the failure reaches the job queue and creates no assistant message' do
      session.update!(status: :generating)
      expect { perform }.to raise_error(/is not enabled/)
      expect(session.messages.assistant).to be_empty
    end
  end

  describe 'when the provider raises' do
    before do
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate)
        .and_raise(Dradis::Plugins::Echo::Provider::HttpStreaming::Error, 'API error (500): secret-host internal body')
      session.update!(status: :generating)
    end

    it 'marks the assistant message failed with a generic, sanitised error' do
      perform
      message = session.messages.assistant.last

      expect(message).to be_failed
      expect(message.metadata['error']).to eq(Dradis::Plugins::Echo::Message::GENERIC_ERROR)
      expect(message.metadata['error']).not_to include('secret-host')
    end

    it 'resets the session to idle' do
      perform
      expect(session.reload).to be_idle
    end
  end

  describe 'when our own code raises a non-provider error' do
    before do
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate).and_raise(ArgumentError, 'genuine bug')
      session.update!(status: :generating)
    end

    it 're-raises so the bug reaches the failed queue instead of being swallowed' do
      expect { perform }.to raise_error(ArgumentError, 'genuine bug')
    end
  end

  describe 'retrying after a failed reply' do
    it 'sends only complete turns on the retry, recovers, and unlocks the session' do
      session.update!(status: :generating)

      # First attempt: the provider fails, leaving a failed assistant row with
      # no content — exactly the turn that must never be replayed.
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate)
        .and_raise(Dradis::Plugins::Echo::Provider::HttpStreaming::Error, 'boom')
      perform

      failed = session.messages.assistant.last
      expect(failed).to be_failed
      expect(failed.content).to be_nil

      # Retry: capture the context handed to the provider.
      sent_context = nil
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate) do |_provider, **kwargs, &block|
          sent_context = kwargs[:messages]
          block.call('Recovered answer.')
        end
      session.update!(status: :generating)
      perform

      # The failed, nil-content turn is excluded — no poison-pill.
      expect(sent_context.map { |turn| turn[:content] }).to all(be_present)
      expect(sent_context).not_to include(a_hash_including(content: nil))

      expect(session.reload).to be_idle
      expect(session.messages.assistant.complete.last.content).to eq('Recovered answer.')
    end
  end
end
