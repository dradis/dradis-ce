class CreateAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_agents do |t|
      # default: 1 maps to the :user enum value
      t.integer :agent_type, default: 1, null: false
      t.boolean :enabled, default: true, null: false
      t.string :model_override
      t.string :name, null: false

      t.text :env

      t.references :provider, null: false, foreign_key: { to_table: :dradis_plugins_echo_providers }
      t.timestamps
    end

    add_index :dradis_plugins_echo_agents, :name, unique: true

    # Seed data is also in engines/dradis-echo/db/seeds.rb for fresh installs
    # (db:prepare loads the schema and runs seeds, skipping migration bodies).
    # This block handles the upgrade path — existing instances running db:migrate
    # don't run seeds, so Roslin must be created here.
    reversible do |dir|
      dir.up do
        address = config_value('roslin_ollama_address') || Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_ADDRESS
        model = config_value('roslin_ollama_model') || Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_MODEL

        provider = Dradis::Plugins::Echo::Provider::Ollama.create!(
          address: address,
          model: model,
          name: 'Ollama'
        )

        next if Dradis::Plugins::Echo::Agent.exists?(name: 'Roslin')

        enabled = config_value('roslin_enabled') != 'false'
        lt_address = Dradis::Plugins::Echo::LanguageToolService::DEFAULT_ADDRESS

        Dradis::Plugins::Echo::Agent.create!(
          agent_type: :system,
          enabled: enabled,
          env: { 'LANGUAGETOOL_ADDRESS' => lt_address },
          name: 'Roslin',
          provider: provider
        )

        Configuration.where('name LIKE ?', 'echo:roslin_%').delete_all
      end
    end
  end

  private

  def config_value(key)
    Configuration.find_by(name: "echo:#{key}")&.value
  end
end
