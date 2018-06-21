class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :subscribable, polymorphic: true
      t.references :user, index: true
    end

    add_index :subscriptions,
              [:subscribable_id, :subscribable_type, :user_id],
              unique: true,
              name: 'uniqueness_index'
  end
end
