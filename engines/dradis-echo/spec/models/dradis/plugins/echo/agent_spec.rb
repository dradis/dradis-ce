require 'rails_helper'
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/providers', __dir__)

describe Dradis::Plugins::Echo::Agent do
  describe 'validations' do
    subject { build(:agent) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should belong_to(:provider) }
  end

  describe 'enum' do
    it 'defaults to user' do
      agent = described_class.new
      expect(agent).to be_user
    end

    it 'supports system type' do
      agent = build(:system_agent)
      expect(agent).to be_system
    end
  end

  describe 'deletion protection' do
    it 'prevents destroying system agents' do
      agent = create(:system_agent)
      expect(agent.destroy).to be false
      expect(described_class.exists?(agent.id)).to be true
    end

    it 'allows destroying user agents' do
      agent = create(:agent)
      expect(agent.destroy).to be_truthy
      expect(described_class.exists?(agent.id)).to be false
    end
  end
end
