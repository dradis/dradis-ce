require 'rails_helper'

describe Dradis::Plugins::Echo::ConfigurationForm do
  describe '#valid?' do
    it 'is valid when all agent sub-forms are valid' do
      form = described_class.from_storage
      expect(form).to be_valid
    end

    it 'does not raise when a nested agent form is nil' do
      form = described_class.new
      expect { form.valid? }.not_to raise_error
    end

    it 'is invalid when a nested agent form is invalid' do
      form = described_class.from_storage
      allow(form.public_send(Dradis::Plugins::Echo::Roslin.form_key))
        .to receive(:valid?).and_return(false)
      allow(form.public_send(Dradis::Plugins::Echo::Roslin.form_key))
        .to receive(:errors).and_return(
          [instance_double(ActiveModel::Error, message: 'is invalid')]
        )
      expect(form).not_to be_valid
    end
  end
end
