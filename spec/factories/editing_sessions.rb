FactoryBot.define do
  factory :editing_session do
    association :user
    record_type { 'Issue' }
    record_id { create(:issue).id }
  end
end
