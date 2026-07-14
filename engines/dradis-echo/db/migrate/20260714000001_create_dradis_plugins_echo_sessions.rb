class CreateDradisPluginsEchoSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_sessions do |t|
      t.references :agent, null: false,
        foreign_key: { to_table: :dradis_plugins_echo_agents }
      t.references :user, null: true,
        foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :record, polymorphic: true, null: false

      # 0 maps to the :idle enum value
      t.integer :status, default: 0, null: false
      t.string :title

      t.timestamps
    end
  end
end
