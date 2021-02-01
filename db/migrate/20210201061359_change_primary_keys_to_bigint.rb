class ChangePrimaryKeysToBigint < ActiveRecord::Migration[6.1]
  def up
    change_table :active_storage_attachments do |t|
      t.change :record_id, :bigint
      t.change :blob_id, :bigint
    end

    change_table :activities do |t|
      t.change :trackable_id, :bigint
      t.change :user_id, :bigint
    end

    change_table :boards do |t|
      t.change :node_id, :bigint
    end

    change_table :cards do |t|
      t.change :list_id, :bigint
      t.change :previous_id, :bigint
    end

    change_table :evidence do |t|
      t.change :issue_id, :bigint
      t.change :node_id, :bigint
    end

    change_table :lists do |t|
      t.change :board_id, :bigint
      t.change :previous_id, :bigint
    end

    change_table :nodes do |t|
      t.change :parent_id, :bigint
    end

    change_table :notes do |t|
      t.change :category_id, :bigint
      t.change :node_id, :bigint
    end

    change_table :notifications do |t|
      t.change :notifiable_id, :bigint
      t.change :actor_id, :bigint
      t.change :recipient_id, :bigint
    end

    change_table :subscriptions do |t|
      t.change :subscribable_id, :bigint
      t.change :user_id, :bigint
    end

    change_table :taggings do |t|
      t.change :tag_id, :bigint
    end

    change_table :versions do |t|
      t.change :item_id, :bigint
    end
  end

  def down
    change_table :active_storage_attachments do |t|
      t.change :record_id, :int
      t.change :blob_id, :int
    end

    change_table :activities do |t|
      t.change :trackable_id, :int
      t.change :user_id, :int
    end

    change_table :boards do |t|
      t.change :node_id, :int
    end

    change_table :cards do |t|
      t.change :list_id, :int
      t.change :previous_id, :int
    end

    change_table :evidence do |t|
      t.change :issue_id, :int
      t.change :node_id, :int
    end

    change_table :lists do |t|
      t.change :board_id, :int
      t.change :previous_id, :int
    end

    change_table :nodes do |t|
      t.change :parent_id, :int
    end

    change_table :notes do |t|
      t.change :category_id, :int
      t.change :node_id, :int
    end

    change_table :notifications do |t|
      t.change :notifiable_id, :int
      t.change :actor_id, :int
      t.change :recipient_id, :int
    end

    change_table :subscriptions do |t|
      t.change :subscribable_id, :int
      t.change :user_id, :int
    end

    change_table :taggings do |t|
      t.change :tag_id, :int
    end

    change_table :versions do |t|
      t.change :item_id, :int
    end
  end
end
