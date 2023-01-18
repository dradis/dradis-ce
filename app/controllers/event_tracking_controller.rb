class EventTrackingController < AuthenticatedController
  include ProjectScoped

  def index
    render layout: 'tylium'
  end
end
