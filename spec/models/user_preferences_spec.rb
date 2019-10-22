require 'rails_helper'

describe UserPreferences do
  it "provides an empty set of preferences with defaults if none have been initialized" do
    subject.class::VALID_TOURS << :tour_rspec1

    up1 = UserPreferences.new
    expect(up1.last_tour_rspec1).to eq('0')

    up1 = UserPreferences.new(tour_tour_rspec1: '1')
    expect(up1.last_tour_rspec1).to eq('1')
  end

  # UPGRADE: this is the right place to test
  context "loading from YAML" do
    # context "valid tour name" do
    #   it "returns 0 for a fresh set of preferences for a valid tour" do
    #     subject.class::VALID_TOURS << :tour_rspec4
    #
    #     preferences = subject.class.load "--- !ruby/object:UserPreferences\ntours: {}\n"
    #
    #     expect do
    #       preferences.last_tour_rspec4
    #     end.not_to raise_error
    #
    #     expect(preferences.last_tour_rspec4).to eq('0')
    #   end
    #
    #   it "returns the last tour version of XXX type that was visited for a valid tour" do
    #     subject.class::VALID_TOURS << :tour_rspec5
    #
    #     preferences = subject.class.load "--- !ruby/object:UserPreferences\ntours:\n :tour_rspec5: 2.0.0\n"
    #
    #     expect do
    #       preferences.last_tour_rspec5
    #     end.not_to raise_error
    #
    #     expect(preferences.last_tour_rspec5).to eq('2.0.0')
    #   end
    # end
  end


  context "#last_tour_XXX" do
    context "invalid tour name" do
      it "raises an exception if the tour name isn't valid" do
        expect do
          subject.last_tour_rspec2
        end.to raise_error(UserPreferences::InvalidTourException)
      end
    end

    context "valid tour name" do
      it "returns 0 for a fresh set of preferences for a valid tour" do
        subject.class::VALID_TOURS << :tour_rspec3
        expect do
          subject.last_tour_rspec3
        end.not_to raise_error
        expect(subject.last_tour_rspec3).to eq('0')
      end

      it "returns the last tour version of XXX type that was visited for a valid tour" do
        subject.class::VALID_TOURS << :tour_rspec3
        subject.tours[:tour_rspec3] = '1'

        expect do
          subject.last_tour_rspec3
        end.not_to raise_error
        expect(subject.last_tour_rspec3).to eq('1')
      end
    end
  end

  context "#last_tour_XXX=" do
    it "sets the new tour value" do
      subject.class::VALID_TOURS << :tour_rspec4

      expect do
        subject.last_tour_rspec4 = '2'
      end.not_to raise_error

      expect(subject.last_tour_rspec4).to eq('2')
    end
  end

  context '#digest_frequency' do
    it 'is valid with pre-defined values' do
      described_class::DIGEST_FREQUENCIES.each do |setting|
        subject.digest_frequency = setting
        expect(subject).to be_valid
      end
    end

    it 'is not valid with non-defined values' do
      subject.digest_frequency = 'notvalid'
      expect(subject).to be_invalid
    end

    it 'does not accept pre-defined values symbols' do
      described_class::DIGEST_FREQUENCIES.each do |setting|
        subject.digest_frequency = setting.to_sym
        expect(subject).to be_invalid
      end
    end
  end
end
