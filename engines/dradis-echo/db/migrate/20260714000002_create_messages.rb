class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_messages do |t|
      t.references :session, null: false,
                             foreign_key: { to_table: :dradis_plugins_echo_sessions }
      # Self-referential parent, dormant.
      t.references :parent, null: true,
                            foreign_key: { to_table: :dradis_plugins_echo_messages }
      t.references :user, foreign_key: { to_table: :users, on_delete: :nullify }

      # 0 maps to the :user role
      t.integer :role, default: 0, null: false
      # 0 maps to the :complete status
      t.integer :status, default: 0, null: false
      t.text :content
      t.text :metadata

      t.timestamps
    end
  end
end
