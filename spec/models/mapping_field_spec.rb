require 'rails_helper'

describe MappingField do
  subject { create(:mapping_field) }

  it { should belong_to(:mapping) }

  it { should validate_presence_of(:content) }

  it { should validate_presence_of(:destination_field) }
  it { should validate_presence_of(:source_field) }

  it { should validate_uniqueness_of(:destination_field).scoped_to([:mapping_id, :source_field]) }
end
