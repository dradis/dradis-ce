class AddChildrenCountToNodes < ActiveRecord::Migration
  class Node < ActiveRecord::Base
    # The 'real' Node class in app/models/node.rb passes the option
    # `counter_cache: true` to `acts_as_tree`. But for some reason, when
    # that option is present, it interferes with this migration and prevents it
    # from working properly because the line
    # `node.update_attributes!(children_count: node.children.count) doesn't
    # actually update anything; it appears to work but after the migration is
    # done every node still has 'children_count' set to 0. 
    #
    # Overriding `Node` with this dummy nested class where `counter_cache:
    # true` is not present solves the issue and makes the initialization of the
    # column data work correctly.
    #
    acts_as_tree
  end

  def change
    add_column :nodes, :children_count, :integer, default: 0, null: false

    reversible do |d|
      d.up do
        # I've tried several approaches to migrating the existing data and this
        # is the fastest I can get it. When testing with about 11,000 Nodes in
        # my database, this entire migration takes about 15 seconds to run on
        # my machine.
        Node.select(:id, :parent_id).where.not(parent_id: nil).includes(:parent).find_each do |node|
          Node.update(node.parent_id, children_count: node.parent.children_count + 1)
        end
      end
    end
  end
end
