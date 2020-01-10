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

  context "loading from YAML" do
    context "valid tour name" do
      it "returns 0 for a fresh set of preferences for a valid tour" do
        preferences = subject.class.load "--- !ruby/object:UserPreferences\ntours: {}\n"

        expect do
          preferences.last_first_sign_in
        end.not_to raise_error

        expect(preferences.last_first_sign_in).to eq('0')
      end

      it "returns the last tour version of XXX type that was visited for a valid tour" do
        preferences = subject.class.load "--- !ruby/object:UserPreferences\ntours:\n :first_sign_in: '2.0.0'\n"

        expect do
          preferences.last_first_sign_in
        end.not_to raise_error

        expect(preferences.last_first_sign_in).to eq('2.0.0')
      end
    end

    it "only serializes designated attributes" do
      preferences = UserPreferences.new
      yaml = UserPreferences.dump(preferences)

      expect(yaml).to eq "--- !ruby/object:UserPreferences\ndigest_frequency: instant\ntours: {}\n"
      expect(yaml).not_to include 'errors'
    end
  end

  context "#last_tour_XXX" do
    context "invalid tour name" do
      it "raises an exception if the tour name isn't valid" do
        expect do
          subject.last_tour_rspec2
        end.to raise_error(NoMethodError)
      end
    end

    context "valid tour name" do
      it "returns 0 for a fresh set of preferences for a valid tour" do
        expect do
          subject.last_first_sign_in
        end.not_to raise_error
        expect(subject.last_first_sign_in).to eq('0')
      end

      it "returns the last tour version of XXX type that was visited for a valid tour" do
        subject.tours[:first_sign_in] = '1'

        expect do
          subject.last_first_sign_in
        end.not_to raise_error
        expect(subject.last_first_sign_in).to eq('1')
      end
    end
  end

  context "#last_projects_show=" do
    it "sets the new tour value" do
      expect do
        subject.last_projects_show = '2'
      end.not_to raise_error

      expect(subject.last_projects_show).to eq('2')
    end
  end

  context '#digest_frequency' do
    it do
      should validate_inclusion_of(:digest_frequency).
        in_array(described_class::DIGEST_FREQUENCIES)
    end

    it 'does not accept values as symbols' do
      should_not validate_inclusion_of(:digest_frequency).
        in_array(described_class::DIGEST_FREQUENCIES.map(&:to_sym))
    end
  end
end
