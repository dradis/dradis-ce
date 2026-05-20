require 'rails_helper'
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Roslin::IssueInteractionJob do
  let(:interaction_id) { 'project-1' }
  let(:response_id)    { 'response-1' }
  let(:prompt)         { 'Summarise this issue.' }

  def perform
    described_class.perform_now(
      prompt: prompt,
      interaction_id: interaction_id,
      response_id: response_id
    )
  end

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
  end

  describe 'when Issue Interaction is not enabled' do
    before do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:enabled?).and_return(false)
    end

    it 'broadcasts a user-friendly error' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to) do |_, **kwargs|
        expect(kwargs[:html]).to include('Issue Interaction is not enabled')
      end
    end
  end

  describe 'when no provider is configured' do
    before do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:enabled?).and_return(true)
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:provider).and_raise('No provider configured for Issue Interaction.')
    end

    it 'broadcasts the error message' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to) do |_, **kwargs|
        expect(kwargs[:html]).to include('No provider configured for Issue Interaction.')
      end
    end
  end

  describe 'error message sanitisation' do
    before do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:enabled?).and_return(true)
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:provider).and_raise('<script>alert(1)</script>')
    end

    it 'HTML-escapes the error message before broadcasting' do
      perform
      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to) do |_, **kwargs|
        expect(kwargs[:html]).to include('&lt;script&gt;')
        expect(kwargs[:html]).not_to include('<script>')
      end
    end
  end

  describe 'successful streaming' do
    let(:provider) { instance_double(Dradis::Plugins::Echo::Provider::Anthropic) }

    before do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:enabled?).and_return(true)
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:provider).and_return(provider)
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:model).and_return(nil)
      allow(provider).to receive(:generate).and_yield('Hello ').and_yield('world')
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
