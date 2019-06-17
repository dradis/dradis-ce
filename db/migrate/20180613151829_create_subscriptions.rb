class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :subscribable, polymorphic: true
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end

    add_index :subscriptions,
              [:subscribable_id, :subscribable_type, :user_id],
              unique: true,
              name: 'index_subscriptions_on_subscribablue_and_user'
  end
end
