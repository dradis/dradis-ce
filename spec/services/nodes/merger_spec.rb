# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nodes::Merger do
  describe '.call' do
    subject(:merge_nodes) { described_class.call(target_node, source_node) }

    let(:root_node) { create(:node) }
    let(:source_node) { create(:node, parent_id: root_node) }
    let(:target_node) { create(:node, parent_id: root_node) }

    it { should match_array [] }

    it 'moves notes to target node' do
      note = create(:note, node: source_node)
      merge_nodes
      expect(target_node.notes).to include note
    end

    it 'increases the count of target node notes' do
      create(:note, node: source_node)
      expect { merge_nodes }.to change(target_node.notes, :count).by 1
    end

    it 'moves evidence to target node' do
      evidence = create(:evidence, node: source_node)
      merge_nodes
      expect(target_node.evidence).to include evidence
    end

    it 'increases the count of target node evidence' do
      create(:evidence, node: source_node)
      expect { merge_nodes }.to change(target_node.evidence, :count).by 1
    end

    it 'moves activities to target node' do
      activity = create(:activity, trackable: source_node)
      merge_nodes
      expect(target_node.activities).to include activity
    end

    it 'increases the count of target node activities' do
      create(:activity, trackable: source_node)
      expect { merge_nodes }.to change(target_node.activities, :count).by 1
    end

    it 'moves children to target node' do
      child_node = create(:node, parent: source_node)
      merge_nodes
      expect(target_node.children).to include child_node
    end

    it 'increases the count of target node children' do
      create(:node, parent: source_node)
      expect { merge_nodes }.to change(target_node.children, :count).by 1
    end

    it "updates the target node's children counter cache" do
      create(:node, parent: source_node)

      expect { merge_nodes }.to change { target_node.reload.children_count }.by 1
    end

    it 'moves attachments to target node' do
      attachment = create(:attachment, node: source_node)
      merge_nodes
      expect(File.exist?(attachment.fullpath)).to be false
    end

    it 'increases the target node attachment count' do
      create(:attachment, node: source_node)
      expect { merge_nodes }.to change { target_node.attachments.count }.by 1
    end

    describe 'when an error is raised' do
      before do
        expect(source_node).to receive(:destroy).and_raise StandardError
      end

      it 'does not move note' do
        note = create(:note, node: source_node)
        merge_nodes
        expect(target_node.notes).not_to include note
      end

      it 'does not change source node notes count' do
        create(:note, node: source_node)
        expect { merge_nodes }.not_to change(source_node.notes, :count)
      end

      it 'does not move evidence' do
        evidence = create(:evidence, node: source_node)
        merge_nodes
        expect(target_node.evidence).not_to include evidence
      end

      it 'does not change source node evidence count' do
        create(:evidence, node: source_node)
        expect { merge_nodes }.not_to change(source_node.evidence, :count)
      end

      it 'does not move activity' do
        activity = create(:activity, trackable: source_node)
        merge_nodes
        expect(target_node.activities).not_to include activity
      end

      it 'does not change source node activities count' do
        create(:activity, trackable: source_node)
        expect { merge_nodes }.not_to change(source_node.activities, :count)
      end

      it 'does not move children' do
        child_node = create(:node, parent: source_node)
        merge_nodes
        expect(target_node.children).not_to include child_node
      end

      it 'does not change source node children count' do
        create(:node, parent: source_node)
        expect { merge_nodes }.not_to change(source_node.children, :count)
      end

      it 'no changes to counter caches' do
        create(:node, parent: source_node)

        expect { merge_nodes }.not_to change { source_node.reload.children_count }
        expect { merge_nodes }.not_to change { target_node.reload.children_count }
      end

      it 'does not move attachments' do
        attachment = create(:attachment, node: source_node)
        merge_nodes
        expect(File.exist?(attachment.fullpath)).to be true
      end

      it 'does not change source node attachments count' do
        create(:attachment, node: source_node)
        expect { merge_nodes }.not_to change { target_node.attachments.count }
      end
    end
  end
end
