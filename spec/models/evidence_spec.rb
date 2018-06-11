require 'rails_helper'

describe Evidence do

  it { should belong_to :issue }
  it { should belong_to :node }
  it { should have_many(:activities) }

  it { should validate_presence_of :issue }
  it { should validate_presence_of :node }

  describe 'on delete' do
    before do
      @evidence = create(:evidence, node: create(:node))
      @activities = create_list(:activity, 2, trackable: @evidence)
      @evidence.destroy
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a evidence even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @evidence.id
        expect(activity.trackable_type).to eq 'Evidence'
      end
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

    it "provides access to the Node label's as a virtual field" do
      expect(@fields['Label']).to eq('Node Label')
    end
  end
end
