FactoryBot.define do
  factory :mapping do
    component { 'qualys' }
    sequence(:source) { 'asset_evidence' }
    sequence(:destination) { |n| "rtp_#{n}" }
  end
end
