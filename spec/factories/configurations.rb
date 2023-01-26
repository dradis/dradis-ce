FactoryBot.define do
  factory :configuration do
    sequence(:name) { |n| "configuration#{n}" }
    value { "Factory-generated value" }

    trait :analytics_config do
      name { 'admin:analytics' }
      value { 'true' }
    end
  end
end
