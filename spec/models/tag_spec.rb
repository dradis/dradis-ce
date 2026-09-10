require 'rails_helper'

describe Tag do
  describe '#display_name' do
    it 'capitalizes the first letter of the tag' do
      tag = create(:tag, name: '!0000ff_blue')
      expect(tag.display_name).to eq('Blue')
    end

    it 'removes the color part of the tag name if present' do
      tag = create(:tag, name: '!0000ff_blue')
      expect(tag.display_name).to eq('Blue')
    end
  end

  describe '#matches?' do
    it 'returns true when the issue is tagged with it' do
      tag = create(:tag, name: '!0000ff_blue')
      issue = create(:issue)
      issue.tags << tag

      expect(tag.matches?(issue)).to be true
    end

    it 'returns false when the issue is not tagged with it' do
      tag = create(:tag, name: '!0000ff_blue')
      issue = create(:issue)

      expect(tag.matches?(issue)).to be false
    end
  end

  describe '#save' do
    it 'normalizes the name before persisting' do
      tag = Tag.create!(name: '!0000ff_BlUe')
      tag.reload
      expect(tag.name).to eq('!0000ff_blue')
    end
  end

  describe '#valid?' do
    it 'requires a name' do
      tag = Tag.new()
      expect(tag.valid?).to be false
      expect(tag.errors[:name].count).to eq(2)
    end

    it 'requires a unique name' do
      Tag.create!(name: '!0000ff_blue')
      expect(Tag.create(name: '!0000ff_blue').errors[:name].count).to eq(1)
    end

    it 'requires to match format' do
      expect(Tag.create(name: '!ab_d').errors[:name].count).to eq(1)
    end
  end
end
