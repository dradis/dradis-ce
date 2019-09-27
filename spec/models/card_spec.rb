require 'rails_helper'

describe Card do
  it { should belong_to(:list).touch(true) }
  it { should have_and_belong_to_many(:assignees).class_name("User") }
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_length_of(:description).is_at_most(DB_MAX_TEXT_LENGTH) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:list) }

  it { should validate_length_of(:name).is_at_most(DB_MAX_STRING_LENGTH) }

  before do
    @board = create(:board)
    @parent = create(:list, board_id: @board.id)
    @list_item = create(:card, list_id: @parent.id)
  end

  describe 'on create' do
    it 'subscribes new assignees' do
      new_card = build(:card, assignee_ids: create_list(:user, 2).map(&:id))
      expect { new_card.save }.to change {
        Subscription.count
      }.by(2)
    end
  end

  describe 'on update' do
    it 'subscribes new assignees' do
      @list_item.assignee_ids = create_list(:user, 2).map(&:id)
      expect { @list_item.save }.to change {
        Subscription.count
      }.by(2)
    end
  end

  describe 'moving a Card around the List' do
    include_examples 'moving the item'
  end

  describe 'deleting a Card' do
    before do
      PaperTrail.enabled = true

      @list_item2 = create(:card, list_id: @parent.id, previous_id: @list_item.id)
      @activities = create_list(:activity, 2, trackable: @list_item)
      create_list(:comment, 2, commentable: @list_item)
      create_list(:subscription, 2, subscribable: @list_item)
      @list_item.destroy
    end

    after { PaperTrail.enabled = false }

    it 'inserts the board_id into the version' do
      version = PaperTrail::Version.
        where(item_type: 'Card', item_id: @list_item.id).
        order(id: :desc).
        first

      expect(version.object).to include("board_id: #{@board.id}")
    end

    it 'adjusts the link' do
      expect(@list_item2.reload.previous_id).to be_nil
    end

    it "doesn't delete or nullify any associated Activities" do
      # We want to keep records of actions performed on a note even after it's
      # been deleted.
      @activities.each do |activity|
        activity.reload
        expect(activity.trackable).to be_nil
        expect(activity.trackable_id).to eq @list_item.id
        expect(activity.trackable_type).to eq 'Card'
      end
    end

    it 'deletes associated Comments' do
      expect(Comment.where(
        commentable_type: 'Card',
        commentable_id: @list_item.id).count
      ).to eq(0)
    end

    it 'deletes associated Subscriptions' do
      expect(Subscription.where(
        subscribable_type: 'Card',
        subscribable_id: @list_item.id).count
      ).to eq(0)
    end
  end
end
