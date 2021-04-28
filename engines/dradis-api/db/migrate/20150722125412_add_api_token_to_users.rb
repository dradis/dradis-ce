class AddAPITokenToUsers < ActiveRecord::Migration[5.1]
  # Future-proof this migration by ignoring everything in the actual model.
  class User < ActiveRecord::Base; end

  def up
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true

    # Create an API token for all existing users
    User.reset_column_information
    User.find_each do |user|
      user.update_column(:api_token, SecureRandom.base64(18).tr("+/", "-_"))
    end
    change_column :users, :api_token, :string, null: false
  end

  def down
    remove_column :users, :api_token, :string
  end

end
