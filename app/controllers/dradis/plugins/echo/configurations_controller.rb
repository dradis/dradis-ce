module Dradis::Plugins::Echo
  class ConfigurationsController < AuthenticatedController
    include ProjectScoped
    before_action :set_configurations

    def index
    end

    def set_configurations
      @configurations = Engine.settings.all
    end
  end
end
