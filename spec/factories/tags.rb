FactoryBot.define do
  factory :tag do
    sequence(:name){ |n| "!#{n}00abc_test" }
  end
end
