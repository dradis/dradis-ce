FactoryBot.define do
  factory :subscription do
    subscribable { |subscription| subscription.association :issue }
    association :user
  end
end
