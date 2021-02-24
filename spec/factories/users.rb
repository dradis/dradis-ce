FactoryBot.define do
  factory :user do
    sequence(:email){ |n| "user-#{n}@example.com" }
    password_hash { 'test' }

    trait(:admin)
    trait(:author)
  end
end
