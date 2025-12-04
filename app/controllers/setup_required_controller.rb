class SetupRequiredController < ApplicationController
  before_action :setup_required

  private
  def setup_required
    defined?(Dradis::Pro) ? setup_required_pro : setup_required_ce
  end

  # -- CE methods -------------------------------------------------------------
  def setup_required_ce
    if (::Configuration.shared_password == 'improvable_dradis')
      redirect_to new_setup_password_path
    elsif  ::Configuration.where(name: 'admin:usage_sharing').empty?
      redirect_to new_setup_analytics_path
    elsif Node.count.zero?
      # We're using this as a proxy for whether the instance has been configured
      # when we visit a project, the methodology_ and issue_library nodes are
      # created.
      redirect_to new_setup_kit_path
    end
  end

  # -- Pro methods ------------------------------------------------------------
  def setup_required_pro
  end
end
