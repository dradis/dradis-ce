class CreateProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_providers do |t|
      t.string :address
      t.text :api_key
      t.string :model
      t.string :name, null: false
      t.string :type, null: false
      t.timestamps
    end
  end
end
