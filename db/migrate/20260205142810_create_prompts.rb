class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :dradis_plugins_echo_prompts do |t|
      t.string :title, null: false
      t.string :icon, null: false
      t.string :prompt_type, null: false

      t.text :prompt, null: false

      t.integer :visibility, null: false, default: 0

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
