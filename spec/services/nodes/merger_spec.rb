# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nodes::Merger do
  describe '.call' do
    subject(:merge_nodes) { described_class.call(target_node, source_node) }

    let(:root_node) { create(:node) }
    let(:source_node) { create(:node, parent_id: root_node, project: root_node.project) }
    let(:target_node) { create(:node, parent_id: root_node, project: root_node.project) }

    it { should eq source_node }

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
      child_node = create(:node, parent: source_node, project: source_node.project)
      merge_nodes
      expect(target_node.children).to include child_node
    end

    it 'increases the count of target node children' do
      create(:node, parent: source_node, project: source_node.project)
      expect { merge_nodes }.to change(target_node.children, :count).by 1
    end

    it "updates the target node's children counter cache" do
      create(:node, parent: source_node, project: source_node.project)

      expect { merge_nodes }.to change { target_node.reload.children_count }.by 1
    end

    it 'moves attachments to target node' do
      attachment = create(:attachment, node: source_node)
      merge_nodes
      target_attachment = Attachment.find(attachment.filename,
        conditions: { node_id: target_node.id })

      expect(target_attachment).to be_an Attachment

      Attachment.all.each(&:delete)
    end

    it 'increases the target node attachment count' do
      create(:attachment, node: source_node)
      expect { merge_nodes }.to change { target_node.attachments.count }.by 1

      Attachment.all.each(&:delete)
    end

    describe 'property merges' do
      it 'merges basic properties together' do
        source_node = create(:node, :with_properties)
        target_node = create(:node, :with_properties)

        source_node.properties['ip'] = ['1.1.1.1', '1.1.1.3']
        source_node.save

        described_class.call(target_node, source_node)

        expect(target_node.properties['ip']).to eq ['1.1.1.1', '1.1.1.2', '1.1.1.3']
      end

      it 'removes duplicate services' do
        services = [
          { 'port': 123, 'protocol': 'udp', 'state': 'open', 'name': 'NTP' }
        ]

        source_node = build(:node, :with_properties)
        source_node.properties[:services] = services
        source_node.save

        target_node = build(:node, :with_properties)
        target_node.properties[:services] = services
        target_node.save

        described_class.call(target_node, source_node)

        expect(target_node.properties[:services].count).to eq 1
      end

      it 'updates services with matching port and protocol' do
        source_service = {
          'port': 123, 'protocol': 'udp', 'state': 'open', 'name': 'ntp'
        }

        source_node = build(:node, :with_properties)
        source_node.properties[:services] = [source_service]
        source_node.save

        target_service = {
          'port': 123, 'protocol': 'udp', 'state': 'closed', 'name': 'NTP'
        }
        target_node = build(:node, :with_properties)
        target_node.properties[:services] = [target_service]
        target_node.save

        described_class.call(target_node, source_node)

        service = target_node.properties[:services].first
        expect(service['state']).to eq 'open'
        expect(service['name']).to eq 'ntp'
      end

      it 'merges services_extras inforamtion per protocol/port' do
        source_extra = { 'source': 'nessus', 'id': 'some id', 'output': 'a message' }
        source_node = build(:node, :with_properties)
        source_node.properties[:services_extras] = { 'udp/123': [source_extra] }
        source_node.save

        target_extra = { 'source': 'nmap', 'id': 'some id', 'output': 'a message' }
        target_node = build(:node, :with_properties)
        target_node.properties[:services_extras] = { 'udp/123': [target_extra] }
        target_node.save

        described_class.call(target_node, source_node)

        expect(target_node.properties[:services_extras]['udp/123']).to include source_extra
        expect(target_node.properties[:services_extras]['udp/123']).to include target_extra
      end
    end

    describe 'when an error is raised' do
      before do
        expect(Node).to receive(:destroy).and_raise StandardError
      end

      it { should eq source_node }

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
        child_node = create(:node, parent: source_node, project: source_node.project)
        merge_nodes
        expect(target_node.children).not_to include child_node
      end

      it 'does not change source node children count' do
        create(:node, parent: source_node, project: source_node.project)
        expect { merge_nodes }.not_to change(source_node.children, :count)
      end

      it 'no changes to counter caches' do
        create(:node, parent: source_node, project: source_node.project)

        expect { merge_nodes }.not_to change { source_node.reload.children_count }
        expect { merge_nodes }.not_to change { target_node.reload.children_count }
      end

      it 'does not move attachments to target node' do
        create(:attachment, node: source_node)
        expect { merge_nodes }.not_to change { target_node.attachments.count }

        Attachment.all.each(&:delete)
      end

      it 'does not change source node attachments count' do
        create(:attachment, node: source_node)
        expect { merge_nodes }.not_to change { source_node.attachments.count }

        Attachment.all.each(&:delete)
      end
    end
  end
end
