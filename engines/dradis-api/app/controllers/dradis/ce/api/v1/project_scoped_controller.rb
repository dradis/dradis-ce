module Dradis::CE::API
  module V1
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
