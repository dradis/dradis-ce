require 'rails_helper'

describe Node do
  let(:node) { build(:node) }

  it { should validate_presence_of(:label) }

  it "acts as tree and deletes nested nodes on delete" do
    should have_many(:children).class_name("Node").dependent(:destroy)
  end
  it { should have_many(:notes).dependent(:destroy) }
  it { should have_many(:evidence).dependent(:destroy) }
  it { should have_many(:activities) }

  describe "on delete" do
    let(:sample_file) { Rails.root.join('public', 'images', 'rails.png') }

    before do
      node.save!
      @attachment = Attachment.new(sample_file, node_id: node.id)
      @attachment.save
      @activities = create_list(:activity, 2, trackable: node)
      node.destroy
    end

    it "deletes all associated attachments" do
      expect(File.exists?(@attachment.fullpath)).to be false
    end

    it "deletes its corresponding attachment subfolder" do
      expect(File.exists?(Attachment.pwd.join(node.id.to_s))).to be false
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a node even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be nil
        expect(activity.trackable_id).to eq node.id
        expect(activity.trackable_type).to eq "Node"
      end
    end
  end

  describe "positioning" do
    it { should respond_to(:position)  }
    it { should respond_to(:position=) }

    it "assigns a default 0 position if none is provided" do
      node.save!
      expect(node.position).to eq(0)
    end

    it "should keep the position when provided" do
      node = create(:node)
      node.position = 3
      expect(node.save).to be true
      node = Node.last
      expect(node.position).to eq(3)
    end
  end

  it "uses a default type ID if none proviede" do
    node = Node.create(label: 'Foo')
    expect(node.type_id).to eq(Node::Types::DEFAULT)
  end

  it "creates a ISSUELIB node when none exists" do
    Node.destroy_all
    issuelib = Node.issue_library
    expect(Node.count).to eq(1)
    expect(issuelib.type_id).to eq(Node::Types::ISSUELIB)
    issuelib.destroy
  end

  it "returns the ISSUELIB node if one exists" do
    Node.destroy_all
    node = create(:node, type_id: Node::Types::ISSUELIB)
    issuelib = Node.issue_library
    expect(issuelib).to eq(node)
    node.destroy
  end

  describe "properties" do
    it "exposes working setters and getters values" do
      node.set_property(:test_property, 80)
      expect(node.properties[:test_property]).to eq(80)
    end

    it "allows indifferent access to properties" do
      node.set_property(:test_property, 80)
      expect(node.properties[:test_property]).to eq(80)
      expect(node.properties['test_property']).to eq(80)
    end

    it "does nothing when trying to set a property with blank value" do
      node.set_property(:test_property, 80)
      node.set_property(:test_property, nil)
      expect(node.properties[:test_property]).to eq(80)
    end

    context "does nothing when adding the same value it already had" do
      it "ignores same value for simple properties" do
        node.set_property(:test_property, 80)
        node.set_property(:test_property, 80)
        expect(node.properties[:test_property]).to eq(80)
      end

      it "ignores same value for hash properties (same key type)" do
        node.set_property(:test_property, {port: 80, protocol: 'tcp'})
        node.set_property(:test_property, {port: 80, protocol: 'tcp'})

        # Because we're getting a WithIndifferentAccess hash, can't compare
        # directly.
        expect(node.properties[:test_property]).to be_a(Hash)
        expect(node.properties[:test_property][:port]).to eq(80)
        expect(node.properties[:test_property][:protocol]).to eq('tcp')
      end

      it "ignores same value for hash properties (different key type)" do
        # Note that order is important, as internally keys will end up as
        # strings for DB serialisation. If we start sending Symbols, they
        # become Strings and by the time we're setting the second property
        # we'd be comparing strings with strings.
        node.set_property(:test_property, {'port' => 80, 'protocol' => 'tcp'})
        node.set_property(:test_property, {port: 80, protocol: 'tcp'})

        # Because we're getting a WithIndifferentAccess hash, can't compare
        # directly.
        expect(node.properties[:test_property]).to be_a(Hash)
        expect(node.properties[:test_property]['port']).to eq(80)
        expect(node.properties[:test_property]['protocol']).to eq('tcp')
      end
    end

    it "stores value as an array when provided value is an array" do
      node.set_property(:test_property, [80, 22])
      expect(node.properties[:test_property]).to eq([80, 22])
    end

    it "merges provided values with existing values" do
      node.set_property(:test_property, [80, 22])
      node.set_property(:test_property, [80, 21, 110])
      expect(node.properties[:test_property]).to eq([80, 22, 21, 110])
    end

    it "turns property into an array when a second value is added" do
      node.set_property(:test_property, 80)
      node.set_property(:test_property, 22)
      expect(node.properties[:test_property]).to eq([80, 22])
    end

    it "doesn't store value as an array when provided array has only one item" do
      node.set_property(:test_property, [80])
      expect(node.properties[:test_property]).to eq(80)
    end
  end

  describe "#nested_activities" do
    before do
      node.save!
      @activities = [
        create(:update_activity, trackable: node),
        create(:create_activity, trackable: node),
      ]
    end

    context "when the node has no notes/evidence" do
      it "returns activities related to the node" do
        expect(node.nested_activities).to match_array(@activities)
      end
    end

    context "when the node has notes & evidence" do
      before do
        note     = create(:note,     node: node)
        evidence = create(:evidence, node: node)
        @activities.push(
          create(:update_activity, trackable: note),
          create(:create_activity, trackable: note),
          create(:update_activity, trackable: evidence),
          create(:create_activity, trackable: evidence)
        )
      end

      it "returns activities related to the node & its notes & evidence" do
        expect(node.nested_activities).to match_array(@activities)
      end
    end

  end
end
