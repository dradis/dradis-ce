module Dradis::Plugins::Echo
  class ConfigurationsController < AuthenticatedController
    include ProjectScoped
    before_action :set_configurations

    def index
    end

    # def update
    #   if URI::DEFAULT_PARSER.make_regexp(['https']).match?(config_params[:site][:value])
    #     Engine.settings.site = config_params[:site][:value]
    #     Engine.settings.save
    #
    #     @consumer_key = Dradis::Plugins::Jira.generate_consumer_key
    #
    #     if @consumer_key
    #       get_public_key
    #
    #       flash.now[:notice] = 'Your JIRA configuration is updated.'
    #       render :index
    #     else
    #       redirect_to jira.configurations_path, notice: 'Your JIRA configuration is updated.'
    #     end
    #   else
    #     redirect_to jira.configurations_path, alert: 'Invalid format for your JIRA site. Use: "https://your-site.atlassian.net"'
    #   end
    # end
    #
    # private
    #
    # def config_params
    #   params.require(:config).permit(site: [:value])
    # end

    def set_configurations
      @configurations = Engine.settings.all
    end
  end
end
