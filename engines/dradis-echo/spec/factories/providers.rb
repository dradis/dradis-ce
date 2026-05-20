FactoryBot.define do
  factory :provider, class: 'Dradis::Plugins::Echo::Provider::Ollama' do
    sequence(:name) { |n| "Provider #{n}" }
    address { 'http://localhost:11434' }
    model { 'qwen2.5:14b' }

    factory :anthropic_provider, class: 'Dradis::Plugins::Echo::Provider::Anthropic' do
      address { nil }
      api_key { 'sk-ant-test' }
      model { 'claude-sonnet-4-6' }
    end
  end
end
