# frozen_string_literal: true

class Node::SyncSettings
  attr_reader :node

  # TODO in Pro this will need to load the node for the current project
  def self.load
    new(Node.sync_settings)
  end

  def initialize(node)
    if node.type_id != Node::Types::SYNC
      raise 'incorrect node type for Node::SyncSettings'
    end
    @node = node
  end

  def save_value(plugin, key, value)
    validate_plugin_key!(plugin, key)

    node.properties ||= {}
    node.properties[plugin.name] ||= {}
    node.properties[plugin.name][key] = value
    node.save!
  end

  def value(plugin, key)
    validate_plugin_key!(plugin, key)

    node.properties ||= {}
    node.properties[plugin.name] ||= {}
    plugin_data = node.properties[plugin.name]

    plugin_data[key]
  end

  private

    def validate_plugin_key!(plugin, key)
      unless plugin.has_setting?(key)
        raise ArgumentError, "#{plugin} doesn't have a setting called '#{key}'"
      end
    end
end
