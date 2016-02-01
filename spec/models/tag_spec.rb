require 'spec_helper'

describe Tag do
  let(:project){ create(:project)}
  before { Tag.set_project_scope(project) }

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

    it "requires a valid project_id" do
      Tag.set_project_scope(nil)

      tag = Tag.new(name: 'red')
      expect(tag.valid?).to be_false
      expect(tag).to have(1).error_on(:project)

      tag.project_id = 0
      expect(tag.valid?).to be_false
      expect(tag).to have(1).error_on(:project)

      tag.project = project
      expect(tag.valid?).to be_true
    end
  end
end
