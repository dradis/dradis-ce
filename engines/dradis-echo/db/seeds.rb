unless Dradis::Plugins::Echo::Agent.exists?(name: 'Roslin')
  provider = Dradis::Plugins::Echo::Provider::Ollama.find_or_create_by!(name: 'Ollama') do |p|
    p.address = Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_ADDRESS
    p.model = Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_MODEL
  end

  Dradis::Plugins::Echo::Agent.create!(
    agent_type: :system,
    enabled: true,
    env: { 'LANGUAGETOOL_ADDRESS' => Dradis::Plugins::Echo::LanguageToolService::DEFAULT_ADDRESS },
    name: 'Roslin',
    provider: provider
  )
end
