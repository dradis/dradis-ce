FactoryGirl.define do
  factory :evidence do
    content "#[EvidenceBlock1]#\nThis particular instance is terrible!\n\n"
    author "factory_girl"
    association :issue
    association :node
  end
end
