FactoryBot.define do
  factory :tag do
    sequence(:name){ |n| "!00000#{n}_tag" }
  end
end
