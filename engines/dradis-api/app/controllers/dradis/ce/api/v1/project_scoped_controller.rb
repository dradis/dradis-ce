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

      include Dradis::CE::API::ProjectScoped      
    end
  end
end
