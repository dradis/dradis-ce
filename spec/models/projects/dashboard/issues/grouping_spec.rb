require 'rails_helper'

describe Projects::Dashboard::Issues::Grouping do
  let(:project) { Project.new }

  describe '.available' do
    it 'offers the tags grouping' do
      expect(described_class.available(project).map(&:key)).to eq ['tags']
    end
  end

  describe '.find' do
    it 'returns the grouping matching the key' do
      expect(described_class.find(project, 'tags')).to be_a(Projects::Dashboard::Issues::TagsGrouping)
    end

    it 'falls back to the first grouping for an unknown key' do
      expect(described_class.find(project, 'bogus')).to be_a(Projects::Dashboard::Issues::TagsGrouping)
    end

    it 'falls back to the first grouping when there is no key' do
      expect(described_class.find(project, nil)).to be_a(Projects::Dashboard::Issues::TagsGrouping)
    end
  end
end
