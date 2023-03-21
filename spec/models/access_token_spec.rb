require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  subject { AccessToken.new(user: FactoryBot.create(:user)) }

  it { should belong_to :user }

  it { should validate_presence_of :name }
  it { should validate_presence_of :token }
  it { should validate_presence_of :user }

  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
end
