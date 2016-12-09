class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :email,                     :string
      t.column :password_hash,             :string
      #t.column :remember_token,            :string
      #t.column :remember_token_expires_at, :datetime

      t.timestamps
    end
  end

  def self.down
    drop_table "users"
  end
end
