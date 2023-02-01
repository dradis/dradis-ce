class EventTrackingController < AuthenticatedController
  include ProjectScoped
  include Analytic
  include EventTracking
end
