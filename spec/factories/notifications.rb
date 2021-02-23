FactoryBot.define do
  factory :notification do
    notifiable { |notification| notification.association :issue }
    read_at { nil }

    association :actor, factory: :user
    association :recipient, factory: :user

    action { :create }
  end
end
