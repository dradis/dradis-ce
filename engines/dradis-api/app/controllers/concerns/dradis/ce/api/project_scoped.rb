module Dradis::CE::API
  module ProjectScoped
    extend ActiveSupport::Concern

    included do
      before_action :set_project

      helper_method :current_project
    end

    protected

    def set_project
      current_project
    end

    def current_project
      @current_project ||= Project.new
    end
  end
end
