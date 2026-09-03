require 'rails_helper'

describe Dradis::Plugins::Echo::Prompt do
  describe 'validations' do
    subject do
      create(:user).prompts.create!(
        title: 'Summarize', prompt: 'Summarize {{ issue.title }}', scope: 'issue', visibility: :user
      )
    end

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:prompt) }
  end

  describe '.defaults_for' do
    it 'returns only the defaults for the requested scope' do
      expect(described_class.defaults_for(:issue).map(&:scope).uniq).to eq(['issue'])
    end

    it 'returns nothing for a scope with no defaults' do
      expect(described_class.defaults_for(:content_block)).to be_empty
    end
  end
end
