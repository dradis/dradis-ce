FactoryBot.define do
  factory :mapping do
    component { 'qualys' }
    sequence(:source) { |n| "source_#{n}" }
    sequence(:destination) { |n| "rtp_#{n}" }

    trait :export_integration do
      component { 'jira' }
      sequence(:source) { |n| "rtp_#{n}" }
      sequence(:destination) { |n| "project_1_issuetype_#{n}" }
    end
  end
end
