FactoryBot.define do
  factory :activity, aliases: [:create_activity] do
    action { 'create' }
    sequence(:user) { |n| "rspec-user-#{n}" }
    trackable { |activity| activity.association :node }

    factory :update_activity do
      action { 'update' }
    end

    factory :delete_activity do
      action { 'destroy' }
    end
  end
end
