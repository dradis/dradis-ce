FactoryBot.define do
  factory :board do
    sequence(:name){ |n| "Board-#{n}" }
    node { create(:project).methodology_library }

    association :project
  end
end
