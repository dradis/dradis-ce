class AddUserIdForActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :user, index: true

    reversible do |dir|
      dir.up do
        Activity.find_each do |activity|
          id = User.find_by_email(activity.read_attribute(:user)).id
          activity.update_attribute :user_id, id
        end
      end

      dir.down do
        Activity.find_each do |activity|
          email = User.find_by_id(activity.user_id).email
          activity.update_column :user, email
        end
      end
    end

    remove_column :activities, :user, :string
  end
end
