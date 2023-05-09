FactoryBot.define do
  factory :board do
    sequence(:name) { |n| "Board-#{n}" }
    association :project

    after(:build) do |board|
      board.node = board.project.methodology_library unless board.node.present?
    end
  end
end
