FactoryBot.define do
  factory :configuration do
    sequence(:name) { |n| "configuration#{n}" }
    value { "Factory-generated value" }
  end
end
