# frozen_string_literal: true

class SyncController < ProjectScopedController
  def settings
    @plugins = Dradis::Plugins.list.select do |plugin|
      plugin.included_modules.include?(Dradis::Plugins::Sync)
    end
    @settings_node = Node::SyncSettings.load
  end

  def update_setting
    find_sync_plugin

    respond_to do |format|
      format.html { head :method_not_allowed }

      format.js do
        node = Node::SyncSettings.load
        if node.save_value(@plugin, params[:setting][:key], params[:setting][:value])
          render json: { success: true }
        else
          render json: @config.errors.to_json, status: :unprocessable_entity
        end
      end
    end
  end

  private

    def sync_plugins
      Dradis::Plugins.list.select do |plugin|
        plugin.included_modules.include?(Dradis::Plugins::Sync)
      end
    end

    # This filter locates the Dradis::Plugins subclass
    # for which we're updating the settings using the :id param.
    # If no plugin is found, an error page is rendered.
    def find_sync_plugin
      if params[:plugin_id]
        class_name = "Dradis::Plugins::#{params[:plugin_id].camelize}::Engine"
        if sync_plugins.any? { |sp| sp.to_s == class_name }
          @plugin = class_name.constantize
        end
      end

      if @plugin.nil?
        raise ActionController::RoutingError.new('Not Found')
      else
        true
      end
    end
end
