FactoryBot.define do
  factory :node do
    label { "Node-#{Time.now.to_i}" }
    parent_id { nil }

    trait :with_project do
    end
  end
end
