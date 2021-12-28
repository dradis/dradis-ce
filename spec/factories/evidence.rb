FactoryBot.define do
  factory :evidence do
    content { "#[EvidenceBlock1]#\nThis particular instance is terrible!\n\n" }
    author { "factory_bot" }
    association :node

    after(:build) do |evidence|
      unless evidence.issue
        evidence.issue = create(:issue, node: evidence.node.project.issue_library)
      end
    end
  end
end
