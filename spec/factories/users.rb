FactoryGirl.define do
  factory :user do
    sequence(:email){ |n| "user-#{n}@example.com" }
    trait :admin do
    end
    trait :author do
    end
  end
end
