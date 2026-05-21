FactoryBot.define do
  factory :agent, class: 'Dradis::Plugins::Echo::Agent' do
    sequence(:name) { |n| "Agent #{n}" }
    agent_type { :user }
    enabled { true }
    provider

    factory :system_agent do
      agent_type { :system }
    end
  end
end
