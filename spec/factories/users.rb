FactoryGirl.define do
  factory :user do
    sequence(:email){ |n| "user-#{n}@example.com" }
  end
end
