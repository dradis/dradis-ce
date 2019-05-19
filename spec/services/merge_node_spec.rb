require 'rails_helper'

RSpec.describe MergeNode do
  describe '.execute' do
    subject(:merge_nodes) { described_class.new(node_1, node_2).execute }

    let!(:attachment) { create(:attachment, node: node_1) }
    let!(:activity) { create(:activity, trackable: node_1) }
    let!(:evidence) { create(:evidence, node: node_1, issue: issue) }
    let!(:issue) { create(:issue, node: node_1) }

    let!(:node_0) { create(:node, label: 'Node 0', project: Project.new) }
    let!(:node_1) { create(:node, label: 'Node 1', parent: node_0) }
    let!(:node_2) { create(:node, label: 'Node 2', parent: node_0) }
    let!(:node_3) { create(:node, label: 'Node 3', parent: node_1) }
    # Tree:
    #
    # - node_0
    #   - node_1
    #     - node_3
    #   - node_2


    context 'when transaction successful' do
      before { merge_nodes }
      after do
        delete_attachment_for node_1, node_2
      end

      it 'deletes source node' do
        expect(Node.find_by(label: 'Node 1')).to eq nil
      end

      it 'moves children to target node' do
        expect(node_2.children).to include(node_3)
      end

      it 'transfers associations to target node' do
        node_2.reload
        expect(node_2.evidence.first).to eq(evidence)
        expect(node_2.issues.first).to eq(issue)
        expect(node_2.activities.first).to eq(activity)
        expect(File.exists?(node_2.attachments.first)).to be(true)
      end
    end

    context 'when transaction fails' do
      before do
        allow(Node).to receive(:reset_counters).and_raise(StandardError)
      end
      after do
        delete_attachment_for node_1
      end

      it 'does not delete source node' do
        expect(Node.find_by(label: 'Node 1')).to eq(node_1)
      end

      it 'does not move children to target node' do
        expect(node_2.children).to eq([])
      end

      it 'does not transfer associations to target node' do
        expect(node_2.evidence.first).not_to eq(evidence)
        expect(node_2.issues.first).not_to eq(issue)
        expect(node_2.activities.first).not_to eq(activity)
        expect(node_2.attachments).to eq([])
      end
    end
  end

  def delete_attachment_for(*nodes)
    nodes.each { |node| FileUtils.rm_rf(Attachment.pwd.join(node.id.to_s)) }
  end
end
