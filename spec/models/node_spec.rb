require 'spec_helper'

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
      expect(File.exists?(@attachment.fullpath)).to be_false
    end

    it "deletes its corresponding attachment subfolder" do
      expect(File.exists?(Attachment.pwd.join(node.id.to_s))).to be_false
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a node even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
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
      node.position.should eq(0)
    end

    it "should keep the position when provided" do
      node = create(:node)
      node.position = 3
      node.save.should be_true
      node = Node.last
      node.position.should eq(3)
    end
  end

  it "uses a default type ID if none proviede" do
    node = Node.create(label: 'Foo')
    node.type_id.should eq(Node::Types::DEFAULT)
  end

  it "creates a ISSUELIB node when none exists" do
    Node.destroy_all
    issuelib = Node.issue_library
    Node.count.should eq(1)
    issuelib.type_id.should eq(Node::Types::ISSUELIB)
    issuelib.destroy
  end

  it "returns the ISSUELIB node if one exists" do
    Node.destroy_all
    node = create(:node, :type_id => Node::Types::ISSUELIB)
    issuelib = Node.issue_library
    issuelib.should eq(node)
    node.destroy
  end

  describe "properties" do
    it "exposes working setters and getters values" do
      node.set_property(:test_property, 80)
      node.properties[:test_property].should eq(80)
    end

    it "allows indifferent access to properties" do
      node.set_property(:test_property, 80)
      node.properties[:test_property].should eq(80)
      node.properties['test_property'].should eq(80)
    end

    it "does nothing when trying to set a property with blank value" do
      node.set_property(:test_property, 80)
      node.set_property(:test_property, nil)
      node.properties[:test_property].should eq(80)
    end

    it "does nothing when trying to set a property with the same value it already had" do
      node.set_property(:test_property, 80)
      node.set_property(:test_property, 80)
      node.properties[:test_property].should eq(80)
    end

    it "stores value as an array when provided value is an array" do
      node.set_property(:test_property, [80, 22])
      node.properties[:test_property].should eq([80, 22])
    end

    it "merges provided values with existing values" do
      node.set_property(:test_property, [80, 22])
      node.set_property(:test_property, [80, 21, 110])
      node.properties[:test_property].should eq([80, 22, 21, 110])
    end

    it "turns property into an array when a second value is added" do
      node.set_property(:test_property, 80)
      node.set_property(:test_property, 22)
      node.properties[:test_property].should eq([80, 22])
    end

    it "doesn't store value as an array when provided array has only one item" do
      node.set_property(:test_property, [80])
      node.properties[:test_property].should eq(80)
    end
  end

  describe "#nested_activities" do
    let(:project) { create(:project) }
    before do
      node.project = project
      node.save!
      @activities = [
        create(:update_activity, trackable: node, project: project),
        create(:create_activity, trackable: node, project: project),
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
          create(:update_activity, trackable: note,     project: project),
          create(:create_activity, trackable: note,     project: project),
          create(:update_activity, trackable: evidence, project: project),
          create(:create_activity, trackable: evidence, project: project)
        )
      end

      it "returns activities related to the node & its notes & evidence" do
        expect(node.nested_activities).to match_array(@activities)
      end
    end

  end

  describe ".search" do
    it "filters nodes by label matching search term" do
      first = create(:node, label: "First node")
      second = create(:node, label: "Second node")
      term = "first"

      results = Node.search(term: term)

      expect(results.size).to eq 1
      expect(results.first.label).to eq first.label
    end

    it "returns list of matches order by updated_at desc" do
      first = create(:node, label: "First node")
      second = create(:node, label: "Second node")
      term = "node"

      results = Node.search(term: term)

      expect(results.map(&:label)).to eq [second.label, first.label]
    end

    it "behaves as case insensitive search" do
      node = create(:node, label: "Node")
      term = "nODE"

      results = Node.search(term: term)

      expect(results.size).to eq 1
      expect(results.first.label).to eq node.label
    end
  end

end
