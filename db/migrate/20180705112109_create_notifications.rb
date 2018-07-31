class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.string      :action
      t.datetime    :read_at

      t.references  :notifiable, polymorphic: true, index: true

      t.references  :actor, index: true, references: :users
      t.references  :recipient, index: true, references: :users

      t.timestamps
    end
  end
end
