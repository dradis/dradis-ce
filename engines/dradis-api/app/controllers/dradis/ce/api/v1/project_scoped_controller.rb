module Dradis::CE::API
  module V1
    # In Pro the dradispro-api engine overrides 'current_project' by injecting
    # a module into this controller on startup. Unfortunately it won't work
    # properly in development because of code reloading; every time you make a
    # new request, PSController will be reloaded without the module included.
    #
    # Workaround: set 'config.cache_classes = true' in config/development.rb
    # (but don't commit it!) The downside is that you'll now have to restart
    # the server every time you make a change.)
    class ProjectScopedController < Dradis::CE::API::APIController
      include ActivityTracking

      before_action :set_project
      helper_method :current_project

      def set_project
        current_project
      end

      def current_project
        @current_project ||= Project.new
      end
    end
  end
end
