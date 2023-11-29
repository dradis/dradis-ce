require 'rails_helper'

describe Activity do

  it { should belong_to(:trackable) }

  it { should validate_presence_of :action }
  it { should validate_presence_of :trackable_id }
  it { should validate_presence_of :trackable_type }
  it { should validate_presence_of :user }

  it { should validate_inclusion_of(:action).in_array %i[create update destroy] }

  describe '#trackable=' do
    context 'when passed an Issue' do
      it 'sets trackable_type as Issue, not Note' do
        # Default Rails behaviour is to set trackable_type to 'Note' when you
        # pass an Issue, meaning that it gets loaded as a Note, not an Issue,
        # when you call #trackable later.
        issue    = create(:issue)
        activity = create(:activity, trackable: issue)
        expect(activity.trackable_type).to eq 'Issue'
        expect(activity.reload.trackable).to eq issue
      end
    end
  end

  describe '#filter_by_user_id' do
    before do
      issue = create(:issue)
      @user = create(:user)
      activity = create(:activity, trackable: issue, user: @user)
      activity2 = create(:activity, trackable: issue, user: @user)
      activity3 = create(:activity, trackable: issue)
    end

    context 'when passed a valid user id' do
      it 'returns activities of this user' do
        expect(Activity.filter_by_user_id(@user.id).count).to eq 2
        expect(Activity.all.count).to eq 3
      end
    end

    context 'when passed a non valid user id' do
      it 'returns an empty collection' do
        user_id = User.last.id + 1
        expect(Activity.filter_by_user_id(user_id).count).to eq 0
        expect(Activity.all.count).to eq 3
      end
    end
  end

  describe '#filter_by_type' do
    before do
      issue = create(:issue)
      card = create(:card)
      activity = create(:activity, trackable: issue)
      activity2 = create(:activity, trackable: card)
      activity3 = create(:activity, trackable: card)
    end

    context 'when passed a valid type' do
      it 'returns activities of this user' do
        expect(Activity.filter_by_type('Card').count).to eq 2
        expect(Activity.all.count).to eq 3
      end
    end

    context 'when passed a non valid type' do
      it 'returns an empty collection' do
        expect(Activity.filter_by_type('galaxy').count).to eq 0
        expect(Activity.all.count).to eq 3
      end
    end
  end

  describe '#filter_by_date' do
    before do
      issue = create(:issue)
      activity = create(:activity, trackable: issue)
      activity2 = create(:activity, trackable: issue, created_at: DateTime.now.beginning_of_year - 1.year)
      activity3 = create(:activity, trackable: issue, created_at: DateTime.now.beginning_of_year - 1.year)
    end

    context 'when passed a valid date' do
      it 'returns activities within the date' do
        year_start = DateTime.now.beginning_of_year
        last_year_start = year_start - 1.year
        period_end = DateTime.now.end_of_day

        expect(Activity.filter_by_date(year_start, period_end).count).to eq 1
        expect(Activity.filter_by_date(last_year_start, period_end).count).to eq 3
      end
    end
  end
end
