require 'rails_helper'
require File.expand_path('../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider do
  describe 'ALLOWED_TYPES' do
    it 'is populated by subclasses' do
      expect(described_class::ALLOWED_TYPES).to include('Anthropic', 'Gemini', 'Ollama', 'OpenAI')
    end
  end

  describe 'validations' do
    subject { build(:provider) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:name) }
  end

  describe 'Ollama validations' do
    subject { build(:provider) }

    it { should validate_presence_of(:address) }

    it 'rejects a non-URL address' do
      subject.address = 'not a url'
      expect(subject).not_to be_valid
      expect(subject.errors[:address]).to include('must be a valid HTTP(S) URL')
    end

    it 'rejects an address without a scheme' do
      subject.address = 'localhost:11434'
      expect(subject).not_to be_valid
    end

    it 'accepts a valid HTTP address' do
      subject.address = 'http://localhost:11434'
      expect(subject).to be_valid
    end

    it 'accepts a valid HTTPS address' do
      subject.address = 'https://ollama.example.com'
      expect(subject).to be_valid
    end
  end

  describe 'OpenAI validations' do
    subject { build(:open_ai_provider) }

    it 'rejects an invalid address when provided' do
      subject.address = 'not a url'
      expect(subject).not_to be_valid
      expect(subject.errors[:address]).to include('must be a valid HTTP(S) URL')
    end

    it 'accepts a blank address (uses default endpoint)' do
      subject.address = nil
      expect(subject).to be_valid
    end

    it 'accepts a valid custom base URL' do
      subject.address = 'https://openai.example.com/v1/'
      expect(subject).to be_valid
    end
  end

  describe '#type_name' do
    it 'returns the demodulized class name' do
      provider = build(:provider)
      expect(provider.type_name).to eq('Ollama')
    end
  end

  describe '#partial_name' do
    it 'returns the underscored class name for use in partial paths' do
      provider = build(:provider)
      expect(provider.partial_name).to eq('ollama')
    end

    it 'handles multi-word type names' do
      provider = Dradis::Plugins::Echo::Provider::OpenAI.new
      expect(provider.partial_name).to eq('open_ai')
    end
  end

  describe '#in_use?' do
    let(:provider) { create(:provider) }

    it 'returns true when the provider is assigned to an agent' do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:settings).and_return(double(provider_id: provider.id))
      expect(provider.in_use?).to be true
    end

    it 'returns false when the provider is not assigned to any agent' do
      allow(Dradis::Plugins::Echo::Roslin::IssueInteraction)
        .to receive(:settings).and_return(double(provider_id: nil))
      expect(provider.in_use?).to be false
    end
  end
end
