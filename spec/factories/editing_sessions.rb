FactoryBot.define do
  factory :editing_session do
    association :user
    record_type { 'Issue' }
    sequence(:record_id) { |n| n }
  end
end
