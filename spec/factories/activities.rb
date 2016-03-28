FactoryGirl.define do
  factory :activity, aliases: [:create_activity] do
    action "create"
    sequence(:user) { |n| "rspec-user-#{n}" }
    trackable_id 1
    trackable_type "Node"

    factory :update_activity do
      action "update"
    end

    factory :delete_activity do
      action "destroy"
    end
  end
end
