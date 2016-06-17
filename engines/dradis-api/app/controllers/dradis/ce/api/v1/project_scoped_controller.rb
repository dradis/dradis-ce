module Dradis::CE::API
  module V1
    class ProjectScopedController < Dradis::CE::API::APIController
      include ActivityTracking
    end
  end
end
