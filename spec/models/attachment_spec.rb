require 'spec_helper'

describe Attachment do
  fixtures :configurations

  before(:each) do
  end

  it "should copy the source file into the attachments folder" do
    node = create(:node)
    attachment = Attachment.new(Rails.root.join('public', 'images', 'rails.png'), node_id: node.id)
    attachment.save
    File.exists?(Attachment.pwd + "#{node.id}/rails.png").should be_true

    node.destroy
  end

  it "should be able to find attachments by filename"
  it "should be able to find all attachments for a given node"
  it "should recognise Ruby file IO and in particular the <<() method"
  it "should be re-nameble"

  describe ".fullpath" do
    it "returns the full file system path to the attachment" do
      node = create(:node)
      attachment = Attachment.new(Rails.root.join('public', 'images', 'rails.png'), node_id: node.id)
      attachment.save

      expect { attachment.fullpath }.not_to raise_error
      expect(attachment.fullpath.to_s).to eq(File.join(Attachment.pwd, node.id.to_s, 'rails.png'))

      node.destroy
    end
  end
end
