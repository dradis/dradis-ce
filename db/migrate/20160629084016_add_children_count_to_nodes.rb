class AddChildrenCountToNodes < ActiveRecord::Migration
  class Node < ActiveRecord::Base
    # The 'real' Node class in app/models/node.rb passed the option
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
        Node.find_each do |node|
          node.update_attributes!(children_count: node.children.count)
        end
      end
    end
  end
end
