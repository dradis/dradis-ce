require 'rails_helper'
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Provider do
  describe 'ALLOWED_TYPES' do
    it 'is populated by subclasses' do
      expect(described_class::ALLOWED_TYPES).to include('Anthropic', 'Gemini', 'Ollama', 'OpenAI')
    end
  end

  describe 'validations' do
    subject { build(:provider) }

    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:name) }

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

    context 'api_key' do
      it 'is required for providers that need one' do
        provider = build(:anthropic_provider, api_key: nil)
        expect(provider).not_to be_valid
        expect(provider.errors[:api_key]).to include("can't be blank")
      end

      it 'is not required for Ollama' do
        provider = build(:provider, api_key: nil)
        expect(provider).to be_valid
      end
    end
  end

  describe '.default_address' do
    it 'raises on the base class' do
      expect { described_class.default_address }.to raise_error(NameError)
    end

    it 'returns the default for each subclass' do
      expect(described_class::Ollama.default_address).to eq('http://localhost:11434')
      expect(described_class::OpenAI.default_address).to eq('https://api.openai.com/v1')
      expect(described_class::Anthropic.default_address).to eq('https://api.anthropic.com/v1/messages')
      expect(described_class::Gemini.default_address).to include('generativelanguage.googleapis.com')
    end
  end

  describe '.default_model' do
    it 'raises on the base class' do
      expect { described_class.default_model }.to raise_error(NameError)
    end

    it 'returns the default for each subclass' do
      expect(described_class::Ollama.default_model).to eq('qwen2.5:14b')
      expect(described_class::OpenAI.default_model).to eq('gpt-4o')
      expect(described_class::Anthropic.default_model).to eq('claude-sonnet-4-6')
      expect(described_class::Gemini.default_model).to eq('gemini-2.5-flash')
    end
  end

  describe '#icon_name' do
    it 'returns the underscored class name' do
      provider = build(:provider)
      expect(provider.icon_name).to eq('ollama')
    end

    it 'handles multi-word type names' do
      provider = Dradis::Plugins::Echo::Provider::OpenAI.new
      expect(provider.icon_name).to eq('open_ai')
    end
  end

  describe '#generate' do
    it 'raises NotImplementedError on the base class' do
      provider = build(:provider)
      # Ollama overrides #generate, so test the base class directly
      expect {
        Dradis::Plugins::Echo::Provider.new.generate(prompt: 'test')
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#requires_api_key?' do
    it 'returns true by default' do
      expect(build(:anthropic_provider).requires_api_key?).to be true
    end

    it 'returns false for Ollama' do
      expect(build(:provider).requires_api_key?).to be false
    end
  end

  describe '#type_name' do
    it 'returns the demodulized class name' do
      provider = build(:provider)
      expect(provider.type_name).to eq('Ollama')
    end
  end
end
