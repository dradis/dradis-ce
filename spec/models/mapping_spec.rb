require 'rails_helper'

describe Mapping do
  it { should have_many(:mapping_fields) }

  it { should validate_presence_of(:component) }
  it { should validate_presence_of(:source) }

  it { should validate_uniqueness_of(:destination).scoped_to([:component, :source]) }
end
