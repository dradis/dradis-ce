FactoryBot.define do
  factory :notification do
    notifiable { |notification| notification.association :issue }
    association :actor, factory: :user
    association :recipient, factory: :user
    action :comment
  end
end
