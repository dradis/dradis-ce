module Tourable
  extend ActiveSupport::Concern

  def should_display_tour?
    tour_name = "#{controller_name}_#{action_name}".to_sym
    @showTour = false
    if TourRegistry.display_for?(tour_name, current_user)
      @showTour = true
      # TourRegistry.displayed_for!(tour_name, current_user)
    end
  end

  module ClassMethods
    def has_tour_for(action)
      before_action :should_display_tour?, only: [action]
    end
  end
end
