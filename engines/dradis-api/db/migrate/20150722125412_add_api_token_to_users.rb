class AddAPITokenToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :api_token, :string, null: false
    add_index :users, :api_token, unique: true

    User.transaction do
      User.find_each do |user|
        # Create an API token for all existing users
        user.update_column(:api_token, SecureRandom.base64(18).tr("+/", "-_"))
      end
    end
  end

  def down
    remove_column :users, :api_token, :string
  end

end
