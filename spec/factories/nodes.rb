FactoryBot.define do
  factory :node do
    label "Node-#{Time.now.to_i}"
    parent_id nil

    trait :with_project do
    end

    factory :sync_node do
      label 'Sync'
      type_id Node::Types::SYNC
    end
  end
end
