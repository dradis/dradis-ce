require 'rails_helper'

describe Attachment do
  fixtures :configurations

  before(:each) do
  end

  it 'should copy the source file into the attachments folder' do
    node = create(:node)
    attachment = Attachment.new(Rails.root.join('public', 'images', 'rails.png'), node_id: node.id)
    attachment.save
    expect(File.exists?(Attachment.pwd + "#{node.id}/rails.png")).to be true

    node.destroy
  end

  it 'should be able to find attachments by filename'
  it 'should be able to find all attachments for a given node'
  it 'should recognise Ruby file IO and in particular the <<() method'
  it 'should be re-nameble'

  describe '.fullpath' do
    it 'returns the full file system path to the attachment' do
      node = create(:node)
      attachment = Attachment.new(Rails.root.join('public', 'images', 'rails.png'), node_id: node.id)
      attachment.save

      expect { attachment.fullpath }.not_to raise_error
      expect(attachment.fullpath.to_s).to eq(File.join(Attachment.pwd, node.id.to_s, 'rails.png'))

      node.destroy
    end
  end

  describe '.copy_to' do
    after do
      Attachment.all.each(&:delete)
    end

    let(:source_node) { create(:node) }
    let(:target_node) { create(:node) }

    it 'copies itself to a target node' do
      attachment = create(:attachment, node: source_node)
      attachment.copy_to(target_node)

      target_attachment = target_node.attachments.first
      expect(
        FileUtils.compare_file(attachment.fullpath, target_attachment.fullpath)
      ).to be true
    end

    it 'increases the number of attachments on the target node' do
      attachment = create(:attachment, node: source_node)
      attachment.copy_to(target_node)

      expect { attachment.copy_to(target_node) }.to change { target_node.attachments.count }
    end

    it 'renames files if the name is already taken' do
      attachment = create(:attachment, node: source_node)
      attachment.copy_to(source_node)

      # Expect the format filename_copy-01.png
      expected_name = attachment.filename.split('.').insert(1, '_copy-01.').join

      last_attachment = source_node.attachments.last
      expect(last_attachment.filename).to eq expected_name
    end
  end
end
