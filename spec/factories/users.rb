FactoryBot.define do
  factory :user do
    sequence(:email){ |n| "user-#{n}@example.com" }
    password_hash 'test'
    trait :admin do
    end
    trait :author do
    end
  end
end
