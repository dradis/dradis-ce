require 'rails_helper'

describe Configuration do

  it { should validate_presence_of :name }
  it { should validate_presence_of :value }
  it { create(:configuration); should validate_uniqueness_of :name }

  it 'validates that an admin:analytics configuration can not have a value other than true or false' do
    expect do
      create(:configuration, name: 'admin:analytics', value: 'lorem')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

end
