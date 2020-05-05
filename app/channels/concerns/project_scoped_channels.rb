# Project scoping for channels. Normally the ProjectScoped concern handles this
# in controllers or API requests. Here we will do it before the channels are
# subscribed when this module is included.
module ProjectScopedChannels
  extend ActiveSupport::Concern

  included do
    before_subscribe :set_project
    before_subscribe :info_for_paper_trail
  end

  def set_project
    current_project
  end

  def current_project
    @current_project ||= Project.new
  end

  def info_for_paper_trail
    PaperTrail.request.controller_info = { project_id: current_project.id }
    PaperTrail.request.whodunnit = current_user.email
  end
end
