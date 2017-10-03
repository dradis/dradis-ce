require 'rails_helper'

describe Tagging do
  describe '#valid?' do
    let(:tag)      { Tag.create!(name: 'pancakes') }
    let(:taggable) { create(:node) }

    it "ensures tags are unique for any given taggable" do
      tagging = Tagging.new
      tagging.tag      = tag
      tagging.taggable = taggable
      tagging.save!

      tagging = Tagging.new
      tagging.tag      = tag
      tagging.taggable = taggable
      expect(tagging.valid?).to be false
      expect(tagging.errors[:tag_id].count).to eq(1)
    end
  end
end
