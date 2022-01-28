require 'rails_helper'

describe User do
  it { should validate_length_of(:email).is_at_most(described_class::DB_MAX_STRING_LENGTH) }
end
