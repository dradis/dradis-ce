require 'rails_helper'

describe UserPreferences do
  it 'provides an empty set of preferences with defaults if none have been initialized' do
    preferences = UserPreferences.new
    expect(preferences.last_first_sign_in).to eq('0')
    expect(preferences.digest_frequency).to eq 'instant'
  end

  it 'accepts defaults for a new set of preferences' do
    preferences = UserPreferences.new(tour_first_sign_in: '1', digest_frequency: 'daily')
    expect(preferences.last_first_sign_in).to eq('1')
    expect(preferences.digest_frequency).to eq 'daily'
  end

  context '#last_tour_XXX' do
    context 'invalid tour name' do
      it "raises an exception if the tour name isn't valid" do
        expect do
          subject.last_tour_rspec2
        end.to raise_error(NoMethodError)
      end
    end

    context 'valid tour name' do
      it 'returns 0 for a fresh set of preferences for a valid tour' do
        expect do
          subject.last_first_sign_in
        end.not_to raise_error
        expect(subject.last_first_sign_in).to eq('0')
      end

      it 'returns the last tour version of XXX type that was visited for a valid tour' do
        subject.tours[:first_sign_in] = '1'

        expect do
          subject.last_first_sign_in
        end.not_to raise_error
        expect(subject.last_first_sign_in).to eq('1')
      end
    end
  end

  context '#last_projects_show=' do
    it 'sets the new tour value' do
      expect do
        subject.last_projects_show = '2'
      end.not_to raise_error

      expect(subject.last_projects_show).to eq('2')
    end
  end

  context '#digest_frequency' do
    it 'validates the digest_frequency' do
      preferences = UserPreferences.new(tour_first_sign_in: '1', digest_frequency: 'test')
      expect(preferences.valid?(nil)).to_not be true

      preferences = UserPreferences.new(tour_first_sign_in: '1', digest_frequency: 'instant')
      expect(preferences.valid?(nil)).to be true
    end
  end

  context 'as user preferences' do
    it 'saves the user preferences' do
      time = Time.now
      user = create(:user)
      user.preferences.last_first_sign_in = time
      user.preferences.last_projects_show = time
      user.preferences.digest_frequency = :daily
      user.save

      expect(user.preferences.last_first_sign_in).to eq(time)
      expect(user.preferences.last_projects_show).to eq(time)
      expect(user.preferences.digest_frequency).to eq(:daily)
    end
  end
end
