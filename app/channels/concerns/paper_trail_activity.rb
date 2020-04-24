module PaperTrailActivity
  extend ActiveSupport::Concern
  include ActivityTracking

  included do
    before_subscribe :set_info
  end

  def set_info
    # In controllers we set PaperTrail metadata in
    # ProjectScoped#info_for_paper_trail, but now
    # we are not in a controller, so:
    PaperTrail.request.controller_info = { project_id: current_project.id }
    PaperTrail.request.whodunnit = current_user.email
  end
end
