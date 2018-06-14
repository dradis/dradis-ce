require 'rails_helper'

describe Subscription do
  it { should belong_to :subscribable }
  it { should belong_to :user }

  it { should validate_presence_of :subscribable }
  it { should validate_presence_of :user }
end
