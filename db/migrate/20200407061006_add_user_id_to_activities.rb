class AddUserIdToActivities < ActiveRecord::Migration[5.2]
  def up
    add_reference :activities, :user, index: true

    Activity.transaction do
      Activity.all.each do |activity|
        user = User.find_by_email(activity.user)
        activity.update_attribute :user_id, user.id if user
      end
    end

    remove_column :activities, :user
  end

  def down
    add_column :activities, :user, :string

    Activity.transaction do
      Activity.all.each do |activity|
        activity.update_column :user, activity.user.try(:email)
      end
    end

    remove_column :activities, :user_id
  end
end
