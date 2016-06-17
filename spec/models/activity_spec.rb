require 'spec_helper'

describe Activity do

  it { should belong_to(:trackable) }

  it { should validate_presence_of :action }
  it { should validate_presence_of :trackable_id }
  it { should validate_presence_of :trackable_type }
  it { should validate_presence_of :user }

  it { should validate_inclusion_of(:action).in_array %i[create update destroy] }

  describe "#trackable=" do
    context "when passed an Issue" do
      it "sets trackable_type as Issue, not Note" do
        # Default Rails behaviour is to set trackable_type to 'Note' when you
        # pass an Issue, meaning that it gets loaded as a Note, not an Issue,
        # when you call #trackable later.
        issue    = create(:issue)
        activity = create(:activity, trackable: issue)
        expect(activity.trackable_type).to eq "Issue"
        expect(activity.reload.trackable).to eq issue
      end
    end
  end

end
