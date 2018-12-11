FactoryBot.define do
  factory :note do
    text { "Note text at #{Time.now}" }
    author { "factory-girl" }
    association :category
    association :node
  end
end
