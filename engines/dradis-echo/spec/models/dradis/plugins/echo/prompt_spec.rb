require 'rails_helper'
require File.expand_path('../../../../factories/prompts', __dir__)

describe Dradis::Plugins::Echo::Prompt do
  describe 'validations' do
    subject { create(:echo_prompt) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:prompt) }

    # Scoped to :scope (not just :user_id) so a title collision in one scope
    # can't block default seeding for another.
    it { should validate_uniqueness_of(:title).scoped_to(:user_id, :scope) }
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
