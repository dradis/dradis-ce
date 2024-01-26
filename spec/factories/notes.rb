FactoryBot.define do
  factory :note do
    sequence(:text) { |n| "#[Title]#\nSample Note #{n}" }
    author { 'factory-girl' }
    association :category
    association :node
  end

  trait :with_liquid do
    content {
      "#[Title]#\nFoo\n\n#[Description]#\nLiquid: {{note.title}}\n\nProject: {{project.name}}"
    }
  end
end
