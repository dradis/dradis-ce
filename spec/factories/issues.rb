FactoryBot.define do
  factory :issue do
    sequence(:text){ |n| "#[Title]#\nRspec multiple Apache bugs #{n}\n\n#[Description]#\nFoo" }
    author "factory_bot"
    category { Category.issue }
    node { Node.issue_library }
  end
end
