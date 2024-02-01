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

  describe 'filtering' do
    before do
      card = create(:card)
      issue = create(:issue)
      @user = create(:user)
      activity = create(:activity, trackable: issue, user: @user, created_at: DateTime.now.beginning_of_year)
      activity2 = create(:activity, trackable: card, user: @user, created_at: DateTime.now.beginning_of_year)
      activity3 = create(:activity, trackable: card, created_at: DateTime.now.beginning_of_year - 1.year)
    end

    describe '#since' do
      context 'when passed a valid date' do
        it 'returns activities within the date' do
          year_start = DateTime.now.beginning_of_year

          expect(Activity.since(year_start).count).to eq 2
        end
      end
    end

    describe '#before' do
      context 'when passed a valid date' do
        it 'returns activities within the date' do
          period_end = DateTime.now.end_of_day - 1.year

          expect(Activity.before(period_end).count).to eq 1
        end
      end
    end
  end
end
