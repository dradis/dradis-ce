require 'rails_helper'

describe Configuration do

  it { should validate_presence_of :name }
  it { should validate_presence_of :value }
  it { create(:configuration); should validate_uniqueness_of :name }

end
