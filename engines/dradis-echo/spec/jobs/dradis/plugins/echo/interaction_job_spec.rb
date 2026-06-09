require 'rails_helper'
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::InteractionJob do
  let(:interaction_id) { 'project-1' }
  let(:response_id)    { 'response-1' }
  let(:prompt)         { 'Summarise this issue.' }
  let(:agent)          { create(:system_agent) }

  def perform
    described_class.perform_now(
      agent_id: agent.id,
      prompt: prompt,
      interaction_id: interaction_id,
      response_id: response_id
    )
  end

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)
  end

  describe 'when agent is not enabled' do
    before { agent.update!(enabled: false) }

    it 'broadcasts a user-friendly error' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to) do |_, **kwargs|
        expect(kwargs[:html]).to include('is not enabled')
      end
    end
  end

  describe 'error message sanitisation' do
    it 'HTML-escapes the error message before broadcasting' do
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate).and_raise('<script>alert(1)</script>')

      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to) do |_, **kwargs|
        expect(kwargs[:html]).to include('&lt;script&gt;')
        expect(kwargs[:html]).not_to include('<script>')
      end
    end
  end

  describe 'successful streaming' do
    before do
      allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
        .to receive(:generate).and_yield('Hello ').and_yield('world')
    end

    it 'removes the spinner on the first chunk' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_remove_to)
        .with([interaction_id, 'prompts'], target: "#{response_id}_spinner")
    end

    it 'broadcasts each chunk to the response target' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to)
        .with([interaction_id, 'prompts'], target: response_id, content: 'Hello ')
      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to)
        .with([interaction_id, 'prompts'], target: response_id, content: 'world')
    end
  end
end
