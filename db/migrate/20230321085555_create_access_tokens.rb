class CreateAccessTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :access_tokens do |t|
      t.string :name
      t.text :token
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
