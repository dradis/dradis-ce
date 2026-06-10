require 'rails_helper'
require File.expand_path('../../../../../factories/agents', __dir__)
require File.expand_path('../../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Agents::Roslin do
  before do
    Dradis::Plugins::Echo::Agent.delete_all
    Dradis::Plugins::Echo::Provider.delete_all
    Configuration.where('name LIKE ?', 'echo:roslin_%').delete_all
  end

  describe '.exists?' do
    it 'ignores non-system agents named Roslin' do
      create(:agent, name: described_class::NAME)

      expect(described_class.exists?).to be false
    end
  end

  describe '.enabled?' do
    it 'returns false when Roslin is not provisioned' do
      expect(described_class.enabled?).to be false
    end
  end

  describe '.language_tool_configured?' do
    it 'returns false when Roslin is not provisioned' do
      expect(described_class.language_tool_configured?).to be false
    end
  end

  describe '.instance' do
    it 'finds the system agent named Roslin' do
      agent = create(:system_agent, name: described_class::NAME)

      expect(described_class.instance).to eq(agent)
    end

    it 'does not find non-system agents named Roslin' do
      create(:agent, name: described_class::NAME)

      expect { described_class.instance }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.provision!' do
    it 'creates Roslin with defaults' do
      agent = described_class.provision!

      expect(agent).to be_system
      expect(agent).to be_enabled
      expect(agent.env).to eq(described_class::DEFAULT_ENV)
      expect(agent.name).to eq(described_class::NAME)
      expect(agent.provider).to have_attributes(
        address: Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_ADDRESS,
        model: Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_MODEL,
        name: 'Ollama'
      )
    end

    it 'uses legacy configuration values when present' do
      create(:configuration, name: 'echo:roslin_enabled', value: 'false')
      create(:configuration, name: 'echo:roslin_ollama_address', value: 'http://ollama.example.test:11434')
      create(:configuration, name: 'echo:roslin_ollama_model', value: 'llama3.3')

      agent = described_class.provision!

      expect(agent).not_to be_enabled
      expect(agent.provider.address).to eq('http://ollama.example.test:11434')
      expect(agent.provider.model).to eq('llama3.3')
      expect(Configuration.where('name LIKE ?', 'echo:roslin_%')).to be_empty
    end

    it 'returns the existing system Roslin without changing admin-managed fields' do
      provider = create(:provider, address: 'http://existing.example.test:11434', model: 'existing-model')
      agent = create(
        :system_agent,
        enabled: false,
        env: { 'CUSTOM' => 'value' },
        name: described_class::NAME,
        provider: provider
      )
      create(:configuration, name: 'echo:roslin_enabled', value: 'true')

      expect(described_class.provision!).to eq(agent)
      expect(agent.reload).not_to be_enabled
      expect(agent.env).to eq('CUSTOM' => 'value')
      expect(agent.provider).to eq(provider)
      expect(Configuration.where('name LIKE ?', 'echo:roslin_%')).to be_empty
    end

    it 'raises when a non-system agent is already named Roslin' do
      create(:agent, name: described_class::NAME)

      expect { described_class.provision! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Dradis::Plugins::Echo::Provider.exists?(name: 'Ollama')).to be false
    end
  end
end
