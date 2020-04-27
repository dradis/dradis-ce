# This module exists to assist with PaperTrail::Version properties in Channels.
# Typically the controllers take care of this but this request process does not
# utilize controllers. In controllers we set PaperTrail metadata in
# ProjectScoped#info_for_paper_trail. For channels we will do it here as a
# before_subscribe action.
module PaperTrailActivity
  extend ActiveSupport::Concern

  included do
    before_subscribe :set_info
  end

  def set_info
    PaperTrail.request.controller_info = { project_id: current_project.id }
    PaperTrail.request.whodunnit = current_user.email
  end
end
