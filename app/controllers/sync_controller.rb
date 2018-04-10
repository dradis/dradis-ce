class SyncController < ProjectScopedController
  def settings
    @plugins = Dradis::Plugins.list.select do |plugin|
      plugin.included_modules.include?(Dradis::Plugins::Sync)
    end
    @settings_node = Node::SyncSettings.load
  end
end
