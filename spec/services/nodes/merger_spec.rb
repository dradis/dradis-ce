# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nodes::Merger do
  describe '.call' do
    subject(:merge_nodes) { described_class.call(target_node.id, source_node) }

    let(:root_node) { create(:node) }
    let(:source_node) { create(:node, parent_id: root_node) }
    let(:target_node) { create(:node, parent_id: root_node) }

    it { should match_array [] }

    it 'moves notes to target node', :aggregate_failures do
      note = create(:note, node: source_node)

      expect { merge_nodes }.to change(target_node.notes, :count).by 1
      expect(target_node.notes).to include note
    end

    it 'moves evidence to target node', :aggregate_failures do
      evidence = create(:evidence, node: source_node)

      expect { merge_nodes }.to change(target_node.evidence, :count).by 1
      expect(target_node.evidence).to include evidence
    end

    it 'moves activities to target node', :aggregate_failures do
      activity = create(:activity, trackable: source_node)

      expect { merge_nodes }.to change(target_node.activities, :count).by 1
      expect(target_node.activities).to include activity
    end

    it 'moves children to target node', :aggregate_failures do
      child_node = create(:node, parent: source_node)

      expect { merge_nodes }.to change(target_node.children, :count).by 1
      expect(target_node.children).to include child_node
    end

    it "updates the source node's children counter cache" do
      create(:node, parent: source_node)

      expect { merge_nodes }.to change { source_node.reload.children_count }.by -1
    end

    it "updates the target node's children counter cache" do
      create(:node, parent: source_node)

      expect { merge_nodes }.to change { target_node.reload.children_count }.by 1
    end

    it "move's attachments to target node", :aggregate_failures do
      attachment = create(:attachment, node: source_node)

      expect { merge_nodes }.to change { target_node.attachments.count }.by 1
      expect(File.exist?(attachment.fullpath)).to be false
    end

    it 'executes a given block within the transaction' do
      block = double
      expect(block).to receive(:called!)

      described_class.call(target_node.id, source_node) do
        block.called!
      end
    end

    describe 'when an error is raised' do
      subject(:merge_nodes) {
        described_class.call(target_node.id, source_node) do
          raise StandardError
        end
      }

      it { should match_array ['StandardError'] }

      it 'source retains notes', :aggregate_failures do
        note = create(:note, node: source_node)

        expect { merge_nodes }.not_to change(source_node.notes, :count)
        expect(target_node.notes).not_to include note
      end

      it 'source retains evidence', :aggregate_failures do
        evidence = create(:evidence, node: source_node)

        expect { merge_nodes }.not_to change(source_node.evidence, :count)
        expect(target_node.evidence).not_to include evidence
      end

      it 'source retains activities', :aggregate_failures do
        activity = create(:activity, trackable: source_node)

        expect { merge_nodes }.not_to change(source_node.activities, :count)
        expect(target_node.activities).not_to include activity
      end

      it 'source retains children', :aggregate_failures do
        child_node = create(:node, parent: source_node)

        expect { merge_nodes }.not_to change(source_node.children, :count)
        expect(target_node.children).not_to include child_node
      end

      it 'no changes to counter caches' do
        create(:node, parent: source_node)

        expect { merge_nodes }.not_to change { source_node.reload.children_count }
        expect { merge_nodes }.not_to change { target_node.reload.children_count }
      end

      it 'source retains attachments', :aggregate_failures do
        attachment = create(:attachment, node: source_node)

        expect { merge_nodes }.not_to change { target_node.attachments.count }
        expect(File.exist?(attachment.fullpath)).to be true
      end
    end
  end
end
