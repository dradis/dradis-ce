FactoryBot.define do
  factory :note do
    sequence(:text){ |n| "#[Title]#\nSample Note #{n}" }
    author { "factory-girl" }
    association :category
    association :node
  end
end
