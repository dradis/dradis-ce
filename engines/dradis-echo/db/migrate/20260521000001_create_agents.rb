class CreateAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_agents do |t|
      t.integer :agent_type, default: 1, null: false
      t.boolean :enabled, default: true, null: false
      t.string :model_override
      t.string :name, null: false
      t.references :provider, null: false,
                   foreign_key: { to_table: :dradis_plugins_echo_providers }
      t.timestamps
    end

    add_index :dradis_plugins_echo_agents, :name, unique: true

    reversible do |dir|
      dir.up do
        roslin_enabled = config_value('echo-roslin', 'enabled') != 'false'
        ii_provider_id = config_value('echo-roslin-issue-interaction', 'provider_id')
        ii_model = config_value('echo-roslin-issue-interaction', 'model')

        provider = if ii_provider_id.present?
                     Dradis::Plugins::Echo::Provider.find_by(id: ii_provider_id)
                   end

        provider ||= Dradis::Plugins::Echo::Provider::Ollama.find_or_create_by!(
          address: 'http://localhost:11434'
        ) do |p|
          p.model = 'qwen2.5:14b'
          p.name = 'Ollama'
        end

        Dradis::Plugins::Echo::Agent.create!(
          agent_type: :system,
          enabled: roslin_enabled,
          model_override: ii_model.presence,
          name: 'Roslin',
          provider: provider
        )

        Configuration.where('name LIKE ?', 'echo-roslin%').delete_all
      end
    end
  end

  private

  def config_value(namespace, key)
    Configuration.find_by(name: "#{namespace}:#{key}")&.value
  end
end
