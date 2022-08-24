require 'rails_helper'

describe Evidence do

  it { should belong_to :issue }
  it { should belong_to :node }
  it { should have_many(:activities) }
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_presence_of :issue }
  it { should validate_presence_of :node }

  describe 'on create' do
    let(:issue) { create(:issue, project: node.project) }
    let(:node) { create(:node) }
    let(:subscribable) { build(:evidence, issue: issue, author: user.email, node: node) }
    let(:user) { create(:user) }

    it_behaves_like 'a subscribable model'
  end

  describe 'on delete' do
    before do
      @evidence = create(:evidence, node: create(:node))
      @activities = create_list(:activity, 2, trackable: @evidence)
      @comments = create_list(:comment, 2, commentable: @evidence)
      @subscriptions = create_list(:subscription, 2, subscribable: @evidence)
      @evidence.destroy
    end

    it 'doesn\'t delete or nullify any associated Activities' do
      # We want to keep records of actions performed on a evidence even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @evidence.id
        expect(activity.trackable_type).to eq 'Evidence'
      end
    end

    it 'deletes associated Comments' do
      expect(Comment.where(
        commentable_type: 'Evidence',
        commentable_id: @evidence.id).count
      ).to eq(0)
    end

    it 'deletes associated Subscriptions' do
      expect(Subscription.where(
        subscribable_type: 'Evidence',
        subscribable_id: @evidence.id).count
      ).to eq(0)
    end
  end

  describe '#fields' do
    before do
      issue = create(:issue)
      node  = create(:node, label: 'Node Label')
      @evidence = Evidence.new(
        node_id: node.id, issue_id: issue.id, content: "#[Output]#\nResistance is futile\n\n"
      )
      @fields = @evidence.fields
    end

    it 'returns #content parsed into a name/value hash' do
      expect(@fields).to have_key 'Output'
      expect(@fields['Output']).to eq 'Resistance is futile'
    end

    it 'provides access to the Node label\'s as a virtual field' do
      expect(@fields['Label']).to eq('Node Label')
    end
  end

  describe '#validate_issue_project' do
    let(:issue) { create(:issue, node: node.project.issue_library, project: node.project) }
    let(:node) { create(:node) }

    context 'when issue is in the same project' do
      it 'is valid' do
        evidence = Evidence.new(node: node, issue: issue)
        expect(evidence.valid?).to eq(true)
      end
    end

    context 'when issue is on a different project' do
      let(:issue_on_another_project) do
        new_node = create(:node)
        allow(new_node).to receive(:project).and_return(Project.new(id: node.project.id + 1, name: 'Another Project'))
        create(:issue, node: new_node)
      end

      it 'is invalid' do
        evidence = Evidence.new(node: node, issue: issue_on_another_project)
        expect(evidence.valid?).to eq(false)
      end
    end
  end
end
