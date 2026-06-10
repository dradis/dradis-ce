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

    # Fresh installs get Roslin through db/seeds.rb. This handles upgrades,
    # where existing instances run migrations without loading seeds.
    reversible do |dir|
      dir.up do
        Dradis::Plugins::Echo::Agents::Roslin.provision!
      end
    end
  end
end
