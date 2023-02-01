class EventTrackingController < AuthenticatedController
  include ProjectScoped
  include Analytic

  def index; end
end
