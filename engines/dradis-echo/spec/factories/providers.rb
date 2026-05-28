FactoryBot.define do
  factory :provider, class: 'Dradis::Plugins::Echo::Provider::Ollama' do
    sequence(:name) { |n| "Provider #{n}" }
    address { 'http://localhost:11434' }
    model { 'qwen2.5:14b' }

    factory :anthropic_provider, class: 'Dradis::Plugins::Echo::Provider::Anthropic' do
      address { 'https://api.anthropic.com/v1/messages' }
      api_key { 'sk-ant-test' }
      model { 'claude-sonnet-4-6' }
    end

    factory :gemini_provider, class: 'Dradis::Plugins::Echo::Provider::Gemini' do
      address { 'https://generativelanguage.googleapis.com/v1beta/models/' }
      api_key { 'AIza-test' }
      model { 'gemini-2.0-flash' }
    end

    factory :open_ai_provider, class: 'Dradis::Plugins::Echo::Provider::OpenAI' do
      address { 'https://api.openai.com/v1/' }
      api_key { 'sk-test' }
      model { 'gpt-4o' }
    end
  end
end
