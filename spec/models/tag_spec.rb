require 'spec_helper'

describe Tag do
  describe '#display_name' do
    it "capitalizes the first letter of the tag" do
      tag = create(:tag)
      expect(tag.display_name).to eq(tag.name.titleize)
    end

    it "removes the color part of the tag name if present" do
      tag = create(:tag, name: '!0000ff_blue')
      expect(tag.display_name).to eq('Blue')
    end

    it "strips the leading bang if the tag consists only of a color description" do
      tag = create(:tag, name: '!0000ff')
      expect(tag.display_name).to eq('0000ff')
    end
  end

  describe '#save' do
    it "normalizes the name before persisting" do
      tag = Tag.create!(name: 'FooBar')
      tag.reload
      expect(tag.name).to eq('foobar')
    end
  end

  describe '#valid?' do
    it "requires a name" do
      tag = Tag.new()
      expect(tag.valid?).to be_false
      expect(tag).to have(1).error_on(:name)
    end

    it "requires a unique name" do
      Tag.create!(name: 'pancakes')
      expect(Tag.create(name: 'Pancakes')).to have(1).error_on(:name)
    end
  end
end
