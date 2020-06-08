FactoryBot.define do
  factory :card do
    sequence(:name){ |n| "Card-#{n}" }
    sequence(:description){ |n| "#[Description]#\nCard-#{n} Description" }
    due_date { 1.week.from_now }
    association :list
  end
end
