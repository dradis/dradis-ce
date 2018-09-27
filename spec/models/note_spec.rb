require 'rails_helper'

describe Note do
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_presence_of(:node) }
  it { should validate_presence_of(:category) }

  it { should have_many(:activities) }

  describe 'on create' do
    let(:user) { create(:user) }
    let(:subscribable) { build(:note, author: user.email) }

    it_behaves_like 'a subscribable model'
  end

  describe 'on delete' do
    before do
      @note = create(:note, node: create(:node))
      @activities = create_list(:activity, 2, trackable: @note)
      @comments = create_list(:comment, 2, commentable: @note)
      @subscriptions = create_list(:subscription, 2, subscribable: @note)
      @note.destroy
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a note even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @note.id
        expect(activity.trackable_type).to eq 'Note'
      end
    end

    it 'deletes associated Comments' do
      expect(Comment.where(
        commentable_type: 'Note',
        commentable_id: @note.id).count
      ).to eq(0)
    end

    it 'deletes associated Subscriptions' do
      expect(Subscription.where(
        subscribable_type: 'Note',
        subscribable_id: @note.id).count
      ).to eq(0)
    end
  end

  describe '#fields' do
    it 'returns #text parsed into a name/value hash' do
      text = <<-EON.strip_heredoc
        #[Title]#
        RSpec Title

        #[Description]#
        Nothing to see here, move on!
      EON
      note = create(:note, text: text)

      expect(note.fields.count).to eq(2)
      expect(note.fields.keys).to match_array(['Title', 'Description'])
      expect(note.fields['Title']).to  eq 'RSpec Title'
      expect(note.fields['Description']).to eq 'Nothing to see here, move on!'
    end
  end

  let(:fields_column) { :text }
  it_behaves_like 'a model that has fields', Note
end
