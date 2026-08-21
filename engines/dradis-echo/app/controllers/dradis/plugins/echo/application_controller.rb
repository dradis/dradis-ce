module Dradis::Plugins::Echo
  class ApplicationController < ::AuthenticatedController
    layout 'dradis/plugins/echo/layouts/sub_nav'

    # The current layout in CE requires a project context. In that case, we're
    # defining the current_project here to fit the requirements of the layout.
    # This can be removed once the authenticated, outside-of-a-project layout is
    # available.
    unless defined?(Dradis::Pro)
      def current_project
        Project.new
      end
      helper_method :current_project
    end
  end
end
