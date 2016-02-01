require 'spec_helper'

describe Tagging do
  describe '#valid?' do
    let(:project)  { create(:project) }
    let(:tag)      { Tag.create!(name: 'pancakes', project_id: project.id) }
    let(:taggable) { create(:node) }

    it "ensures tags are unique for any given taggable" do
      tagging = Tagging.new
      tagging.tag      = tag
      tagging.taggable = taggable
      tagging.save!

      tagging = Tagging.new
      tagging.tag      = tag
      tagging.taggable = taggable
      tagging.should have(1).error_on(:tag_id)
    end
  end
end
