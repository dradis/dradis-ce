module ProjectScopedChannels
  extend ActiveSupport::Concern

  included do
    before_subscribe :set_project
  end

  def set_project
    current_project
  end

  def current_project
    @current_project ||= Project.new
  end
end
