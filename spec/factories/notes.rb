FactoryBot.define do
  factory :note do
    content { "Note text at #{Time.now}" }
    author { "factory-girl" }
    association :category
    association :node
  end
end
