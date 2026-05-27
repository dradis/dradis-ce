RSpec.configure do |config|
  config.before(:suite) do
    provider = Dradis::Plugins::Echo::Provider::Ollama.find_or_create_by!(name: 'Ollama') do |p|
      p.address = Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_ADDRESS
      p.model   = Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_MODEL
    end

    provider.agents.find_or_create_by!(name: 'Roslin') do |a|
      a.agent_type = :system
      a.enabled    = false
      a.env        = { 'LANGUAGETOOL_ADDRESS' => Dradis::Plugins::Echo::LanguageToolService::DEFAULT_ADDRESS }
    end
  end
end
