require 'rails_helper'

describe Notification do
  it { should belong_to :actor }
  it { should belong_to :notifiable }
  it { should belong_to :recipient }

  it { should validate_presence_of :action }
  it { should validate_presence_of :actor }
  it { should validate_presence_of :notifiable }
  it { should validate_presence_of :recipient }
end
