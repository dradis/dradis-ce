require 'spec_helper'

describe Note do

  it { should validate_presence_of(:node) }
  it { should validate_presence_of(:category) }

  it { should have_many(:activities) }

  describe "on delete" do
    before do
      @note = create(:note, node: create(:node))
      @activities = create_list(:activity, 2, trackable: @note)
      @note.destroy
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a note even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @note.id
        expect(activity.trackable_type).to eq "Note"
      end
    end
  end

  describe "#fields" do
    it "returns #text parsed into a name/value hash" do
      text = <<-EON.strip_heredoc
        #[Title]#
        RSpec Title

        #[Description]#
        Nothing to see here, move on!
      EON
      note = create(:note, text: text)

      expect(note.fields.count).to eq(2)
      expect(note.fields.keys).to match_array(['Title', 'Description'])
      expect(note.fields['Title']).to  eq "RSpec Title"
      expect(note.fields['Description']).to  eq "Nothing to see here, move on!"
    end
  end


  describe "#title" do
    let(:note) { Note.new }
    subject { note.title }

    context "when the note has a #[Title]# field" do
      before { note.text = "#[Title]#\nMy Title" }
      it { should eq "My Title" }

      specify "#title? returns true" do
        expect(note.title?).to be true
      end
    end

    context "when the note does not have a #[Title]# field" do
      before { note.text = "#[Not The Title]#\nMy Title" }
      it { should eq "This note doesn't provide a #[Title]# field" }

      specify "#title? returns false" do
        expect(note.title?).to be false
      end
    end
  end
end
