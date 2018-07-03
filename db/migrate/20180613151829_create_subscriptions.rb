class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :subscribable, polymorphic: true
      t.references :user, index: true
    end
  end
end
