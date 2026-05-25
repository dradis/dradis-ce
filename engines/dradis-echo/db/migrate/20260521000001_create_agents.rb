class CreateAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_agents do |t|
      # default: 1 maps to the :user enum value
      t.integer :agent_type, default: 1, null: false
      t.boolean :enabled, default: true, null: false
      t.string :model_override
      t.string :name, null: false

      t.json :env, default: {}

      t.references :provider, null: false,
                   foreign_key: { to_table: :dradis_plugins_echo_providers }
      t.timestamps
    end

    add_index :dradis_plugins_echo_agents, :name, unique: true

    reversible do |dir|
      dir.up do
        address = config_value('roslin_ollama_address') || Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_ADDRESS
        enabled = config_value('roslin_enabled') != 'false'
        model = config_value('roslin_ollama_model') || Dradis::Plugins::Echo::Provider::Ollama::DEFAULT_MODEL

        provider = Dradis::Plugins::Echo::Provider::Ollama.create!(
          address: address,
          model: model,
          name: 'Ollama'
        )

        Dradis::Plugins::Echo::Agent.create!(
          agent_type: :system,
          enabled: enabled,
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
