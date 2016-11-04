require 'spec_helper'

describe Issue do

  let(:issue) { Issue.new }

  it "is assigned to the Category.issue category" do
    node = create(:node)
    # use a block because we can't mass-assign 'node':
    issue = Issue.new { |i| i.node = node }
    expect(issue).to be_valid()
    issue.save
    expect(issue.category).to eq(Category.issue)
  end

  it "affects many nodes through :evidence" do
    issue = create(:issue)
    expect(issue.affected).to be_empty

    host = create(:node, label: '10.0.0.1', type_id: Node::Types::HOST)
    host.evidence.create(author: 'rspec', issue_id: issue.id, content: "#[EvidenceBlock1]#\nThis apache is old!")

    issue.reload
    expect(issue.affected).to_not be_empty
    expect(issue.affected.first).to eq(host)
  end

  it { should have_many(:evidence).dependent(:destroy) }
  it { should have_many(:activities) }

  describe "on delete" do
    before do
      @issue = create(:issue, node: create(:node))
      @activities = create_list(:activity, 2, trackable: @issue)
      @issue.destroy
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a issue even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @issue.id
        expect(activity.trackable_type).to eq "Issue"
      end
    end

  end

  describe "on combine" do
    before do
      node = Node.create(label: 'Foo')

      @issue1 = Issue.new{ |i| i.node = node }
      @issue1.save

      @issue2 = Issue.new{ |i| i.node = node }
      @issue2.save

      @issue1.evidence.create(
        author: 'rspec',
        content: "#[Evidence1]#\nIssue 1 evidence",
        node: node
      )
      @issue2.evidence.create(
        author: 'rspec',
        content: "#[Evidence2]#\nIssue 2 evidence",
        node: node
      )

      @issue1.combine @issue2.id
    end

    it "combines the issues", issues: true do
      @issue1.reload
      expect(@issue1.evidence.length).to eq 2
      expect(Issue.exists?(@issue2.id)).to be false
    end

  end

  let(:fields_column) { :text }
  it_behaves_like "a model that has fields", Issue

  describe "#set_field" do
    it "sets a field and updates 'body'" do
      issue.text = "#[Title]#\nSomething"
      issue.set_field("Title", "New title")
      expect(issue.fields["Title"]).to eq "New title"
      expect(issue.text).to eq "#[Title]#\nNew title"
    end
  end


  describe "#activities" do
    it "returns the issue's activities" do
      # this requires some hackery, because by default it won't work because
      # Issue and Note don't use proper single-table inheritance :(
      node  = create(:node)
      issue = create(:issue, node: node)
      activities = create_list(:activity, 2, trackable: issue)

      # Sanity check that all trackable types are 'Issue', not 'Note'
      expect(activities.map(&:trackable_type).uniq).to eq ["Issue"]

      expect(issue.activities).to be_an(ActiveRecord::Relation)
      expect(issue.activities).to eq activities
    end
  end

  # NOTE: the idea of having an Affected field appended to the automagically was
  # to allow the Affected field content control in AdvancedWordExport to work in
  # the same way the other fields do. However, this introduces a cascading SQL
  # problem every time we access any field, so we've moved the functionality to
  # retrieve the affected hosts to:
  #   AdvancedWordExport::Processors::Ooxml::Processor::populate_field - fields.rb#257
  #
  #it "provides access to the list of Affected fields as another note field" do
  #  issue = create(:issue)
  #  node1 = create(:node)
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Foo')
  #  node2 = create(:node)
  #  node2.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Bar')
  #  issue.reload
  #  issue.fields['Affected'].should eq([node1, node2].collect(&:label).to_sentence)
  #end
  #it "The Affected field contains each host only once" do
  #  issue = create(:issue)
  #  node1 = create(:node)
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Foo')
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Bar')
  #  node2 = create(:node)
  #  node2.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'BarFar')
  #  issue.reload
  #  issue.fields['Affected'].should eq([node1, node2].collect(&:label).to_sentence)
  #end
end
