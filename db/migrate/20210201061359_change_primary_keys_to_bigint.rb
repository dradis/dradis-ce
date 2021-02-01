class ChangePrimaryKeysToBigint < ActiveRecord::Migration[6.1]
  def up
    change_table :active_storage_attachments do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :blob_id, :bigint
      t.change :record_id, :bigint
    end

    change_table :active_storage_blobs do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

    change_table :activities do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :trackable_id, :bigint
      t.change :user_id, :bigint
    end

    change_table :boards do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :node_id, :bigint
    end

    change_table :cards do |t|
      t.change :list_id, :bigint
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :previous_id, :bigint
    end

    change_table :cards_users do |t|
      t.change :card_id, :bigint
      t.change :user_id, :bigint
    end

    change_table :categories do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

   change_table :comments do |t|
      t.change :commentable_id, :bigint
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :user_id, :bigint
    end

    change_table :configurations do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

    change_table :evidence do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :issue_id, :bigint
      t.change :node_id, :bigint
    end

    change_table :lists do |t|
      t.change :board_id, :bigint
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :previous_id, :bigint
    end

    change_table :logs do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

    change_table :nodes do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :parent_id, :bigint
    end

    change_table :notes do |t|
      t.change :category_id, :bigint
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :node_id, :bigint
    end

    change_table :notifications do |t|
      t.change :actor_id, :bigint
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :notifiable_id, :bigint
      t.change :recipient_id, :bigint
    end

    change_table :subscriptions do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :subscribable_id, :bigint
      t.change :user_id, :bigint
    end

    change_table :taggings do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :tag_id, :bigint
      t.change :taggable_id, :bigint
    end

    change_table :tags do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

    change_table :users do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
    end

    change_table :versions do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :bigint, unique: true, null: false, auto_increment: true
      end
      t.change :item_id, :bigint
      t.change :project_id, :bigint
    end
  end

  def down
    change_table :active_storage_attachments do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :blob_id, :int
      t.change :record_id, :int
    end

    change_table :active_storage_blobs do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

    change_table :activities do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :trackable_id, :int
      t.change :user_id, :int
    end

    change_table :boards do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :node_id, :int
    end

    change_table :cards do |t|
      t.change :list_id, :int
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :previous_id, :int
    end

    change_table :cards_users do |t|
      t.change :card_id, :int
      t.change :user_id, :int
    end

    change_table :categories do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

   change_table :comments do |t|
      t.change :commentable_id, :int
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :user_id, :int
    end

    change_table :configurations do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

    change_table :evidence do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :issue_id, :int
      t.change :node_id, :int
    end

    change_table :lists do |t|
      t.change :board_id, :int
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :previous_id, :int
    end

    change_table :logs do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

    change_table :nodes do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :parent_id, :int
    end

    change_table :notes do |t|
      t.change :category_id, :int
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :node_id, :int
    end

    change_table :notifications do |t|
      t.change :actor_id, :int
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :notifiable_id, :int
      t.change :recipient_id, :int
    end

    change_table :subscriptions do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :subscribable_id, :int
      t.change :user_id, :int
    end

    change_table :taggings do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :tag_id, :int
      t.change :taggable_id, :int
    end

    change_table :tags do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

    change_table :users do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
    end

    change_table :versions do |t|
      if ActiveRecord::Base.connection.adapter_name != 'SQLite'
        t.change :id, :int, unique: true, null: false, auto_increment: true
      end
      t.change :item_id, :int
      t.change :project_id, :int
    end
  end
end
